@echo off
echo Configurando ambiente virtual para PDF Storage API...

REM Mudar para o diretório do script
cd /d %~dp0

REM Criar ambiente virtual se não existir
if not exist venv (
    python -m venv venv
    echo Ambiente virtual criado.
) else (
    echo Ambiente virtual já existe.
)

REM Ativar ambiente virtual
call venv\Scripts\activate.bat

REM Instalar dependências
pip install -r requirements.txt

REM Executar a aplicação
echo Iniciando servidor...
uvicorn main:app --reload --host 0.0.0.0 --port 8000