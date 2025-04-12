import re
from pathlib import Path

def convert_matlab_rules_to_python(matlab_rules_text, output_txt_path, output_py_path):
    # Dicionários de mapeamento
    input_vars = {
        0: 'humedad',
        1: 'acidez',
        2: 'rigidez',
        3: 'factor_disp',
        4: 'gases',
        5: 'polimerizacion'
    }
    
    input_terms = {
        'humedad': ['Bueno', 'Moderado', 'Malo'],
        'acidez': ['Bueno', 'Moderado', 'Malo'],
        'rigidez': ['Malo', 'Moderado', 'Bueno'],  # Ordem invertida
        'factor_disp': ['Bueno', 'Moderado', 'Malo'],
        'gases': ['Bueno', 'Moderado', 'Malo'],
        'polimerizacion': ['Bueno', 'Muy-malo', 'Moderado-bajo', 'Moderado-alto', 'Malo']
    }
    
    output_terms = {
        1: 'Muy-malo',
        2: 'Malo',
        3: 'Moderado',
        4: 'Bueno',
        5: 'Muy-Bueno'
    }

    # Processar cada regra
    python_rules = []
    py_code_rules = []
    
    for line in matlab_rules_text.split('\n'):
        if not line.strip() or 'Rules' in line:
            continue
            
        # Extrair a parte das regras (ex: [0,0,0,0,0,2,5 (1) : 1])
        match = re.search(r'\[([^\]]+)\]', line)
        if not match:
            continue
            
        rule_part = match.group(1)
        components = [x.strip() for x in rule_part.split(',')]
        
        # Extrair inputs e output
        try:
            inputs = [int(x) for x in components[:6]]
            output = int(components[6].split('(')[0])
        except (ValueError, IndexError):
            continue
            
        # Construir a regra em Python
        rule_parts = []
        for i, idx in enumerate(inputs):
            var_name = input_vars[i]
            term = input_terms[var_name][idx] if idx >= 0 else input_terms[var_name][idx]
            rule_parts.append(f"{var_name}['{term}']")
            
        python_rule = " & ".join(rule_parts)
        output_term = output_terms[output]
        
        # Formatar para arquivo txt
        python_rules.append(f"Regra MATLAB: {line.strip()}")
        python_rules.append(f"Python: ctrl.Rule({python_rule}, salida['{output_term}'])")
        python_rules.append("")
        
        # Formatar para código Python executável
        py_code_rules.append(f"ctrl.Rule({python_rule}, salida['{output_term}'])")
    
    # Salvar em arquivo txt
    with open(output_txt_path, 'w', encoding='utf-8') as f:
        f.write("REGRAS CONVERTIDAS DE MATLAB PARA PYTHON\n")
        f.write("="*50 + "\n\n")
        f.write("\n".join(python_rules))
    
    # Gerar código Python completo
    py_code = (
        "import skfuzzy as fuzz\n"
        "from skfuzzy import control as ctrl\n\n"
        "# Variáveis de entrada e saída (definidas anteriormente)\n"
        "# ... (seu código existente para criar antecedentes/consequentes)\n\n"
        "# Regras convertidas automaticamente:\n"
        "rules = [\n"
        f"    {',\n    '.join(py_code_rules)}\n"
        "]\n\n"
        "# Criar sistema de controle\n"
        "health_ctrl = ctrl.ControlSystem(rules)\n"
        "health_index = ctrl.ControlSystemSimulation(health_ctrl)\n"
    )
    
    with open(output_py_path, 'w', encoding='utf-8') as f:
        f.write(py_code)
    
    print(f"Conversão concluída! Arquivos salvos em:")
    print(f"- Regras em texto: {output_txt_path}")
    print(f"- Código Python pronto: {output_py_path}")

# Exemplo de uso:
matlab_rules = """
[System]
Name='Romeromodificado'
Type='mamdani'
Version=2.0
NumInputs=6
NumOutputs=1
NumRules=80
AndMethod='min'
OrMethod='max'
ImpMethod='min'
AggMethod='sum'
DefuzzMethod='centroid'

[Rules]
0 0 0 0 0 2, 5 (1) : 1
0 0 0 0 -3 5, 4 (1) : 1
0 0 0 0 3 5, 5 (1) : 1
3 3 1 0 -3 4, 4 (1) : 1
3 3 0 3 -3 4, 4 (1) : 1
"""

# Configurar caminhos de saída
output_dir = Path(r"C:\Users\felip\Desktop\Fuzzy Python")
output_dir.mkdir(exist_ok=True)

convert_matlab_rules_to_python(
    matlab_rules,
    output_dir / "regras_convertidas.txt",
    output_dir / "fuzzy_system_automatico.py"
)