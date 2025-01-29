##REQUESITOS

-UBUNTU 20.04 

-JA POSSUIR INSTALADO NO SEU SERVIDOR UMA VERSAO DE WHATICKET SAAS COM BANCO POSTGRES

CRIAR SUBDOMINIO E APONTAR PARA O IP DA SUA VPS EXEMPLO: pgadmin.seudominio.com

CHECAR PROPAGAÇÃO DO DOMÍNIO https://dnschecker.org/

##RODAR OS COMANDOS ABAIXO NO SEU SERVIDOR SSH

apt update && apt upgrade -y

apt install sudo dos2unix -y 

sudo git clone https://github.com/Whaticket-Free/Instalador-PgAdmin-Whaticket-SaaS.git && cd Instalador-PgAdmin-Whaticket-SaaS && sudo chmod +x ./pgadmin.sh

dos2unix pgadmin.sh

./pgadmin.sh

AGORA E SO SEGUIR COM AS INSTUÇOES NA TELA DE SEU SERVIDOR 

