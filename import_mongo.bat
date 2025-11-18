@echo off
setlocal ENABLEDELAYEDEXPANSION

REM Script para importar dados JSON para MongoDB - RemoteReady
REM Uso: import_mongo.bat [<uri>]
REM Se nenhum argumento for passado, usa o URI local padrão

set "DEFAULT_URI=mongodb://localhost:27017/remoteready"

if "%~1"=="" (
	set "URI=%DEFAULT_URI%"
) else (
	set "URI=%~1"
)

REM Detecta mongoimport: primeiro tenta PATH, depois caminhos comuns de instalacao
set "MONGOIMPORT="
where mongoimport >nul 2>&1
if not errorlevel 1 (
	set "MONGOIMPORT=mongoimport"
) else (
	if exist "%ProgramFiles%\MongoDB\Tools\100\bin\mongoimport.exe" (
		set "MONGOIMPORT=%ProgramFiles%\MongoDB\Tools\100\bin\mongoimport.exe"
	) else if exist "C:\Program Files\MongoDB\Tools\100\bin\mongoimport.exe" (
		set "MONGOIMPORT=C:\Program Files\MongoDB\Tools\100\bin\mongoimport.exe"
	) else if exist "%ProgramFiles(x86)%\MongoDB\Tools\100\bin\mongoimport.exe" (
		set "MONGOIMPORT=%ProgramFiles(x86)%\MongoDB\Tools\100\bin\mongoimport.exe"
	)
)

if "%MONGOIMPORT%"=="" (
	echo ERRO: mongoimport nao encontrado no PATH nem em caminhos padrao.
	echo Instale as MongoDB Database Tools ou ajuste o PATH.
	echo Veja: https://www.mongodb.com/docs/database-tools/installation/
	pause
	endlocal
	exit /b 1
)

echo =========================================================================
echo IMPORTACAO REMOTEREADY PARA MONGODB
echo =========================================================================
echo Usando: %MONGOIMPORT%
echo URI: %URI%
echo =========================================================================

for %%C in (
	usuarios
	empresas
	blog_posts
	certificados
	user_posts
	chat_history
) do (
	echo ===============================================================================
	echo Importando %%C ...
	if exist "remoteready_%%C.json" (
		"%MONGOIMPORT%" --uri "%URI%" --collection "%%C" --file "remoteready_%%C.json" --jsonArray --drop
		if errorlevel 1 (
			echo ERRO ao importar remoteready_%%C.json
		) else (
			echo OK: remoteready_%%C.json importado em %%C
		)
	) else (
		echo AVISO: arquivo remoteready_%%C.json nao encontrado, pulando.
	)
)

echo ============================================================================
echo COMANDOS ADICIONAIS (se necessario):
echo ============================================================================
echo Para verificar as colecoes criadas:
echo   mongosh remoteready --eval "show collections"
echo.
echo Para verificar dados importados:
echo   mongosh remoteready --eval "db.usuarios.countDocuments()"
echo   mongosh remoteready --eval "db.empresas.countDocuments()"
echo   mongosh remoteready --eval "db.blog_posts.countDocuments()"
echo.
echo Para consultar dados de exemplo:
echo   mongosh remoteready --eval "db.usuarios.find().limit(3)"
echo ============================================================================
echo Importacao concluida.
endlocal
pause