**Instalação Automatizada – PJe Office + SafeSign TokenAdmin**

(Distribuições Debian/Ubuntu)

Este repositório contém um script Bash que automatiza a instalação do PJe Office Pro e do SafeSign TokenAdmin, facilitando a configuração necessária para uso de certificados digitais em sistemas **Debian, Ubuntu, Mint e derivados.**

**📋 O que o Script Faz**

1. Verifica dependências

Checa e instala, se necessário, pacotes básicos como wget, unzip e tar.

2. Instala o PJe Office Pro

Baixa a versão oficial mais recente.

Descompacta e move os arquivos para a pasta correta no $HOME do usuário.

3. Instala o SafeSign TokenAdmin

Faz download do middleware SafeSign.

Cria atalho automático no menu de aplicativos e, se desejado, na área de trabalho.

4. Interface opcional de confirmação

Caso dialog ou whiptail estejam instalados, exibe uma tela de confirmação antes de prosseguir.

**🖥️ Requisitos do Sistema**

Distribuição: Debian, Ubuntu Mint ou derivadas.

Permissões: acesso de superusuário (root).

Pacotes necessários:

**sudo apt update** \
**sudo apt install git wget unzip tar**

(opcional) dialog ou whiptail se quiser a interface ncurses.

**🚀 Passo a Passo de Execução**

**⚠️ Todos os comandos abaixo devem ser executados em um terminal.**

1. Clone o repositório:

$ git clone https://github.com/hudsonalbuquerque97-sys/Instalador-safesing-pjeoffice-pro.git

2. Entre na pasta do projeto:

$ cd Instalador-safesing-pjeoffice-pro

3. Dê permissão de execução ao script:

$ chmod +x Instalador_safesing+pjeofficepro.sh

4. Obtenha privilégio de superusuário (root):

$ sudo su

Digite sua senha de administrador quando solicitado.

5. Execute o script:

./Instalador_safesing+pjeofficepro.sh

6. Siga as instruções exibidas no terminal.

**🧩 Estrutura do Repositório**

. \
├── Instalador_safesing+pjeofficepro.sh \
└── README.md         

**⚠️ Avisos**

O script baixa pacotes diretamente dos sites oficiais do PJe Office e do SafeSign.

Verifique a integridade/assinatura dos arquivos caso deseje maior segurança.

Para usar o SafeSign é necessário possuir token e certificados digitais compatíveis com a ICP-Brasil.

**📄 Licença**

Distribuído sob a licença MIT. Consulte o arquivo LICENSE




