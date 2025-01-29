#!/bin/bash

# Script para instalar o pgAdmin em um servidor com PostgreSQL já instalado e configurar o SSL com Certbot

# Perguntar ao usuário a porta desejada para o pgAdmin
read -p "Digite a porta para o pgAdmin (ex: 9000): " pgadmin_port

# Perguntar ao usuário o domínio para acesso ao pgAdmin
read -p "Digite o domínio para acesso ao pgAdmin (ex: pgadmin.exemplo.com): " pgadmin_domain

# Perguntar o email e senha para o pgAdmin
read -p "Digite o email para o pgAdmin: " pgadmin_email
read -p "Digite a senha para o pgAdmin: " pgadmin_password

# Nome do container pgAdmin
pgadmin_container_name="pgadmin"

# Verificar se o container pgAdmin já existe
if docker ps -a | grep -q "$pgadmin_container_name"; then
  echo "O container pgAdmin já existe. Removendo..."
  docker stop "$pgadmin_container_name"
  docker rm "$pgadmin_container_name"
fi

# Criar o container pgAdmin, vinculando ao PostgreSQL existente
docker run --name "$pgadmin_container_name" -e PGADMIN_DEFAULT_EMAIL="$pgadmin_email" -e PGADMIN_DEFAULT_PASSWORD="$pgadmin_password" -p "$pgadmin_port":80 -d --link postgres:postgres dpage/pgadmin4

# Configurar o Nginx para o pgAdmin (sem SSL por enquanto)
cat > /etc/nginx/sites-available/pgadmin << EOF
server {
  server_name $pgadmin_domain;

  location / {
    proxy_pass http://127.0.0.1:$pgadmin_port;
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOF

# Criar link simbólico para habilitar o site Nginx
ln -s /etc/nginx/sites-available/pgadmin /etc/nginx/sites-enabled/

# Testar a configuração do Nginx
nginx -t

# Reiniciar o Nginx para aplicar as alterações
systemctl restart nginx

# Gerar o certificado SSL com o Certbot
sudo certbot --nginx -d "$pgadmin_domain" -m "$pgadmin_email" --agree-tos --no-interactive

# Modificar o arquivo de configuração do Nginx para usar o SSL
sed -i "s/listen 80;/listen 443 ssl;
    ssl_certificate \/etc\/letsencrypt\/live\/$pgadmin_domain\/fullchain.pem;
    ssl_certificate_key \/etc\/letsencrypt\/live\/$pgadmin_domain\/privkey.pem;/" /etc/nginx/sites-available/pgadmin

# Testar a configuração do Nginx
sudo nginx -t

# Reiniciar o Nginx para aplicar as alterações
sudo systemctl restart nginx

echo "pgAdmin instalado e configurado com sucesso!"
echo "Acesse o pgAdmin com SSL em: https://$pgadmin_domain"