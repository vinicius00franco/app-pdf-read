#!/bin/bash

echo "Configurando ambiente virtual para PDF Storage API..."

# Criar ambiente virtual se não existir
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo "Ambiente virtual criado."
else
    echo "Ambiente virtual já existe."
fi

# Ativar ambiente virtual
source venv/bin/activate

# Instalar dependências
pip install -r requirements.txt

# Executar a aplicação
echo "Iniciando servidor..."
uvicorn main:app --reload --host 0.0.0.0 --port 8085