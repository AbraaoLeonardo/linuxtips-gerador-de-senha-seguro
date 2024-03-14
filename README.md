# PICK day-03
## Desafio desenvolvido durante o terceiro dia do Programa Itensivo de Container e Kubernetes(PICK)
O desafio consiste em criar uma image da aplicação [gerador de senhas](https://github.com/badtuxx/giropops-senhas). Porém, tem algumas condições: Devemos criar uma imagem distroless e que não há nenhuma CVE.

### Conceitos importantes utilizados:
#### O que é distroless
Quando criamos uma imagem, todas as falhas de segurança da imagem base são passadas para a imagem final. Uma imagem python base possui mais de 600 CVE conhecidos, já a versão slim possui cerca de 100. Distroless é uma imagem que consta apenas o runtime, as bibliotecas da aplicação e os pacotes utilizados pela aplicação. Com isso, a imagem é bem pequena, assim diminuindo o custo de deploy, já que o build e testes são mais rápido, o tempo de deploy é menor, e o tráfego é reduzido, assim diminuindo a conta de tráfego da sua conta na núvem.

#### trivy
Trivy é uma ferramenta que consegue escanear nossa imagem em busca de CVEs. Além de mostrar os CVEs, caso o pacote tenha alguma versão que ela foi corrigida, ele nos apresentará uma sugestão de quais versões podemos atualizar para corrigir esse problema.

- imagem do trivy-redis

## Como executar o projeto.
Primeiro, você deverá possuir instalado as seguintes ferramentas:
1. Docker - [mac](https://docs.docker.com/desktop/install/mac-install/) | [linux](https://docs.docker.com/desktop/install/linux-install/) | [windows](https://docs.docker.com/desktop/install/windows-install/)
1. Opcional - [trivy](https://aquasecurity.github.io/trivy/v0.18.3/installation/)
Com as ferramentas instaladas, abra o terminal e execute os seguintes comandos:
```
docker container run -d -p 6379:6379 --name redis redis # Irá executar um container do banco de dados redis
docker container run -d -p 5000:5000 -e REDIS_HOST=<IP da sua máquina> --name giropops abraaoleonardo284/gerador-de-senha-distroless:1.0 # A aplicação em python
```
### Possíveis erros:
1. Na sua máquina, alguma porta pode estar sendo utilizada. Altere a porta em `-p <porta que pode ser alterada>:<porta que não pode ser alterável>` 


## Problemas e desáfios enfrentados
### Primeiro problema.
Antes de colocar a aplicação rodando em distroless, decidi me certificar que ela roda na minha máquina. Executei o comando e deu erro de dependência.
```
from werkzeug.urls import url_quote
E   ImportError: cannot import name 'url_quote' from 'werkzeug.urls'
```
Verificando na internet, vi que é um problema na versão do flask que não suporta o werkzeug instalado e a solução era adicionar o `Werkzeug>=2.2.0`. Com isso deu certo executar na minha máquina. 

Executei o container sem o `Werkzeug>=2.2.0` mas apresentou o mesmo problema. Gerei a imagem com e deu certo subir a aplicação.

### Segundo problema.
Agora que a aplicação está rodando, vou alterar a imagem para distroless. Usei a imagem python-dev e a python da chainguard para subir a aplicação mas deu problema que o comando flask não estava funcionando.
#### Soluções que não deram certos.
1. Decidi executar apenas na DEV para testar mas não executou.
2. Decidi executar o container com o `CMD ["python","app.py"]` porém deu problema com a falta de um host
3. Em meu computador, usei o comando which para encontrar o executável do flask, e tentei utilizar o caminho do packet do flask para executar, mas não deu certo. Conseguia executar mas apresentava erro com um pacote dos pacotes que compõe o flask.
4. Com dúvidas de como funcionava a imagem, tentei acessar via shell, mas não estava conseguindo acessar mesmo usando a vesão de dev.
#### Solução
Como o comando python estava sendo executado, testei a imagem com o comando `["python", "-m", "flask","run","--host=0.0.0.0"]` e deu certo. Configurei um container redis para executar a aplicação e funcionou