# Instruções de implantação (produção) — MinIO via Nginx na porta 80

Este documento descreve os passos necessários para expor o MinIO através do Nginx em produção usando um subdomínio (ex.: `minio.seudominio.com`) na porta 80.

1) DNS
- Crie um registro `A` (ou `CNAME`) para o subdomínio apontando para o IP público do servidor onde o Docker rodará.

2) Ajuste do Nginx
- No arquivo de configuração do Nginx (`nginx/minio.conf`), altere `server_name _;` para o subdomínio desejado:

  server {
    listen 80;
    server_name minio.seudominio.com;
    ...
  }

- Se quiser o console web em outro hostname (`console.seudominio.com`) crie um segundo bloco `server` com `proxy_pass http://minio:9001;`.
- Alternativamente, exponha o console em `/console/` (requer ajustes de paths no proxy).

3) docker-compose
- Garanta que `docker-compose.yml` contenha o serviço `nginx` com mapeamento `80:80` e volume apontando para a configuração: já incluído em `docker-compose.yml`.
- Exemplo mínimo (já presente no repositório):

  nginx:
    image: nginx:stable-alpine
    container_name: legado-nginx
    restart: unless-stopped
    depends_on:
      minio:
        condition: service_healthy
    ports:
      - "80:80"
    volumes:
      - ./nginx/minio.conf:/etc/nginx/conf.d/default.conf:ro

4) Firewall e portas
- Abra a porta 80 no firewall (ex.: `ufw allow 80` ou regra equivalente no provedor de nuvem).

5) Testes locais antes do DNS propagar
- Para testar sem apontar o DNS globalmente, use a opção `Host` no curl:

  curl -I -H "Host: minio.seudominio.com" http://<IP_DO_SERVIDOR>

- Ou, ao trabalhar localmente no próprio host, teste com:

  docker-compose up -d
  curl -I -H "Host: minio.seudominio.com" http://localhost

6) Reiniciar/atualizar Nginx
- Após alterar `nginx/minio.conf`, recarregue a configuração:

  docker-compose restart legado-nginx
  # ou dentro do container:
  docker-compose exec legado-nginx nginx -s reload

7) Console web do MinIO (opcional)
- O console padrão roda em `:9001`. Para mapear para outro hostname ou path, crie outro `server` no Nginx com `proxy_pass http://minio:9001;` e ajuste cabeçalhos/proxy_buffering conforme necessário.

8) HTTPS — recomendado para produção
- Use Let's Encrypt para emitir certificados. Opções comuns:
  - Instalar `certbot` no host e configurar o Nginx com os certificados gerados (recomendado para maior controle).
  - Usar um container de proxy com ACME automático (ex.: Traefik, `nginx-proxy` + `letsencrypt-nginx-proxy-companion`).

- Exemplo rápido (Certbot + Nginx):
  1. Pare/pare o container `legado-nginx` temporariamente.
  2. Instale `certbot` no host e rode: `certbot certonly --nginx -d minio.seudominio.com`.
  3. Aponte o `nginx/minio.conf` para os caminhos dos certificados e reinicie o container.

9) Observações e boas práticas
- Use nomes de host separados para API S3 e console se precisar comportamentos diferentes.
- Monitore logs do Nginx e MinIO com `docker-compose logs -f legado-nginx legado-minio`.
- Em ambientes com balanceador ou proxy adicional, preserve cabeçalhos `Host` e `X-Forwarded-*` para que o MinIO opere corretamente.

10) Comandos úteis

  docker-compose up -d
  docker-compose ps
  docker-compose logs -f legado-nginx
  curl -I -H "Host: minio.seudominio.com" http://localhost

Se quiser, eu posso gerar também um exemplo de configuração para o console em `console.seudominio.com` e um trecho pronto para SSL com `server` redirecionando `80 -> 443`.
