================================================================================
                    VOLLEYMATCH - DESCRIÇÃO E FLUXO DO WIREFRAME
================================================================================

--------------------------------------------------------------------------------
1. DESCRIÇÃO DAS TELAS
--------------------------------------------------------------------------------

A interface do VolleyMatch foi desenhada com foco na usabilidade, garantindo 
telas limpas e de operação rápida para evitar cliques desnecessários durante a 
dinâmica de um jogo. A navegação entre os principais módulos é feita de forma 
direta através de uma Bottom Navigation Bar (Barra de Navegação Inferior) 
presente na maioria das telas (Home, Jogadores, Sorteio, Partida).

* Tela Home: 
  Funciona como o dashboard central da aplicação. Apresenta uma mensagem de 
  boas-vindas e dois botões de atalho rápido: "Novo Sorteio" e "Iniciar Jogo". 
  Abaixo, exibe uma seção de "Partidas Recentes", listando o histórico dos 
  últimos confrontos e seus respectivos placares finais de forma resumida.

* Tela Jogadores: 
  Apresenta a lista de todos os atletas cadastrados. Cada card de jogador exibe 
  seu nome, posição tática principal (ex: Ponteiro) e o seu nível de habilidade 
  técnica (ex: 9/10). No topo há uma barra de busca ("Buscar jogador...") e no 
  canto inferior direito há um botão flutuante (+) para adicionar um novo atleta.

* Tela Adicionar Jogador: 
  Formulário para o cadastro rápido de novos participantes. Permite o upload de 
  uma foto de perfil (opcional), um campo de texto para inserir o "Nome", um 
  menu de seleção (dropdown) para definir a "Posição" e um slider interativo 
  para classificar a "Habilidade" (escala de 1 a 10, com marcadores de 
  Iniciante, Intermediário e Avançado). Finaliza com o botão "Adicionar Jogador".

* Tela Editar Jogador: 
  Possui a mesma estrutura de campos da tela de cadastro, mas já preenchida com 
  os dados atuais do atleta selecionado para modificações. Conta com o botão 
  "Salvar Alteração" em destaque azul e uma opção de "Remover Jogador" em 
  destaque vermelho logo abaixo.

* Tela Escolher Sorteio: 
  Exibe a listagem dos jogadores cadastrados acompanhada de checkboxes 
  laterais. O organizador utiliza essa tela para marcar apenas os atletas que 
  estão fisicamente presentes no momento do jogo. No topo, um contador exibe a 
  proporção de selecionados (ex: 12/18). Possui o botão "Sortear Times".

* Tela Times: 
  Exibe o resultado gerado pelo algoritmo de balanceamento do aplicativo. Os 
  jogadores selecionados são divididos automaticamente em duas equipes 
  equilibradas ("Time A" e "Time B"), listando os nomes e o nível de cada um. 
  Na parte inferior, há dois botões de ação: "Refazer Sorteio" (caso queiram 
  gerar uma nova combinação) e "Iniciar Partida".

* Tela Partida: 
  O placar dinâmico principal do jogo. Exibe o cronômetro de tempo corrido, o 
  número do Set atual (ex: Set 3/3) e um indicador de "Ao Vivo". A tela é 
  dividida em duas cores para diferenciar o placar do Time A e do Time B, com 
  botões grandes de (+) e (-) para marcação rápida de pontos. Mostra também o 
  histórico dos sets anteriores e o botão amarelo "Ver Rotação Detalhada".

* Tela Rotação: 
  Exibe uma representação visual interativa de uma quadra de vôlei (visão aérea). 
  Posiciona os jogadores titulares do Time A e do Time B de acordo com as 
  posições táticas e a rotação atual da partida. Conta com tags de estado nas 
  extremidades como "Time A Side-out" e "Time B Saque" para orientar os times.

* Tela Placar Ampliada: 
  Uma variação da Tela Partida em modo paisagem (horizontal). Otimiza o espaço 
  da tela para focar exclusivamente nos números do placar, cronômetro e set em 
  tamanho gigante. Ideal para deixar o smartphone ou tablet apoiado próximo à 
  rede, visível para todos os jogadores na quadra.


--------------------------------------------------------------------------------
2. FLUXO PRINCIPAL DA APLICAÇÃO (CAMINHO FELIZ)
--------------------------------------------------------------------------------

O fluxo padrão do usuário para organizar e executar uma partida recreativa 
consiste nos seguintes passos interligados:

1. Cadastro e Atualização (Se necessário):
   O usuário abre o app na "Tela Home" e navega até a aba "Jogadores". Se houver 
   pessoas novas no treino, ele clica no botão (+) para abrir a "Tela Adicionar 
   Jogador", preenche os dados técnicos do novato e o salva na base.

2. Seleção de Presentes e Sorteio:
   O usuário acessa a aba "Sorteio" (Tela Escolher Sorteio) na barra inferior. 
   Ele visualiza a lista de todos os cadastrados e marca o checkbox daqueles 
   que vão jogar no dia. Com a lista fechada, clica no botão "Sortear Times".

3. Validação das Equipes:
   O app calcula o equilíbrio e direciona para a "Tela Times". O usuário avalia 
   a divisão feita pelo algoritmo. Se o grupo concordar com a formação, ele 
   clica em "Iniciar Partida". (Caso queira mudar, clica em "Refazer Sorteio").

4. Controle de Pontuação e Set:
   A aplicação abre a "Tela Partida". À medida que o jogo acontece, o marcador 
   atribui os pontos clicando diretamente nas áreas de (+) e (-) de cada equipe. 
   O sistema gerencia as regras padrão do vôlei e computa o fechamento dos sets 
   automaticamente.

5. Consulta Educacional de Rotação (Opcional):
   Se durante o jogo os times se perderem no rodízio de posições após um ponto 
   de quebra de saque, o marcador clica em "Ver Rotação Detalhada". O app abre a 
   "Tela Rotação", mostrando graficamente onde cada atleta deve se posicionar. 
   Após a consulta, o usuário clica em voltar (<-) para retornar ao placar.

6. Finalização:
   Ao atingir o número de sets necessários para fechar o jogo, o usuário clica 
   em "Encerrar partida". Os dados finais daquele confronto são gravados no 
   banco local e o usuário é redirecionado de volta para a "Tela Home", onde o 
   novo resultado passa a figurar no histórico de "Partidas Recentes".
================================================================================