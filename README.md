# mini-mundo-cinemas-c
Criação de um ambiente de simulação de uma rede de cinemas em Linguagem C. O projeto envolveu a modelagem e representação de entidades e componentes (tela, diretor, zelador, etc.), aplicando lógica de programação para construir a estrutura.
-- Criação das Tabelas

CREATE TABLE CINEMA (
    codigo INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(200) NOT NULL
); [cite: 99, 100, 101, 102, 103]

CREATE TABLE SALA (
    numero INT PRIMARY KEY AUTO_INCREMENT,
    capacidade INT NOT NULL,
    codigo_cinema INT NOT NULL,
    FOREIGN KEY (codigo_cinema) REFERENCES CINEMA(codigo)
); [cite: 104, 105, 106, 107, 108, 109]

CREATE TABLE FILME (
    codigo INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(100) NOT NULL,
    duracao INT NOT NULL,
    genero VARCHAR(50) NOT NULL,
    classificacao VARCHAR(10) NOT NULL,
    diretor VARCHAR(100) NOT NULL
); [cite: 110, 111, 112, 113, 114, 115, 116, 117]

CREATE TABLE SESSAO (
    codigo INT PRIMARY KEY AUTO_INCREMENT,
    data DATE NOT NULL,
    horario TIME NOT NULL,
    numero_sala INT NOT NULL,
    codigo_filme INT NOT NULL,
    FOREIGN KEY (numero_sala) REFERENCES SALA (numero),
    FOREIGN KEY (codigo_filme) REFERENCES FILME(codigo)
); [cite: 118, 119, 120, 121, 122, 123, 124, 125, 126]

CREATE TABLE CLIENTE (
    cpf CHAR(11) PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100)
); [cite: 127, 128, 129, 130, 131, 132]

CREATE TABLE FUNCIONARIO (
    matricula INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cargo VARCHAR(50) NOT NULL,
    telefone VARCHAR(20),
    email VARCHAR(100),
    codigo_cinema INT NOT NULL,
    FOREIGN KEY (codigo_cinema) REFERENCES CINEMA (codigo)
); [cite: 133, 134, 135, 136, 137, 138, 139, 140, 141]

CREATE TABLE INGRESSO (
    codigo INT PRIMARY KEY AUTO_INCREMENT,
    assento VARCHAR(5) NOT NULL,
    valor DECIMAL(8,2) NOT NULL,
    cpf_cliente CHAR(11) NOT NULL,
    codigo_sessao INT NOT NULL,
    matricula_func INT NOT NULL,
    FOREIGN KEY (cpf_cliente) REFERENCES CLIENTE (cpf),
    FOREIGN KEY (codigo_sessao) REFERENCES SESSAO (codigo),
    FOREIGN KEY (matricula_func) REFERENCES FUNCIONARIO(matricula)
); [cite: 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152]

-- Inserção de Dados

INSERT INTO CINEMA (nome, endereco) VALUES
('cine David''s downtown', 'avenida das americas, 123'),
('cine David''s Barrashopping', 'Avenida das Américas, 456'); [cite: 154, 155, 156, 157]

INSERT INTO SALA (capacidade, codigo_cinema) VALUES
(120, 1),
(80, 1),
(100, 2); [cite: 158, 159, 160, 161, 162]

INSERT INTO FILME (titulo, duracao, genero, classificacao, diretor) VALUES
('A Grande Jornada', 130, 'Ação', '12', 'João Silva'),
('Amor em Paris', 95, 'Romance', '10', 'Maria Souza'),
('Mistério Profundo', 115, 'Suspense', '14', 'Carlos Lima'); [cite: 163, 164, 165, 166, 167]

INSERT INTO SESSAO (data, horario, numero_sala, codigo_filme) VALUES
('2025-06-18', '18:00:00', 1, 1),
('2025-06-18', '20:30:00', 2, 2),
('2025-06-19', '19:00:00', 3, 3); [cite: 168, 169, 170, 171, 172]

INSERT INTO CLIENTE (cpf, nome, telefone, email) VALUES
('12345678901', 'Yasmin araujo', '11999999999', 'yasmin.araujo@gmail.com'),
('98765432100', 'Bruno Santos', '21988888888', 'bruno.santos@gmail.com'); [cite: 173, 174, 175, 176]

INSERT INTO FUNCIONARIO (nome, cargo, telefone, email, codigo_cinema) VALUES
('Fernanda Lopes', 'Atendente', '11977777777', 'fernanda.lopes@gmail.com', 1),
('Ricardo Dias', 'Gerente', '21966666666', 'ricardo.dias@gmail.com', 2); [cite: 178, 179, 180, 181]

INSERT INTO INGRESSO (assento, valor, cpf_cliente, codigo_sessao, matricula_func) VALUES
('A01', 25.00, '12345678901', 1, 1),
('B05', 25.00, '98765432100', 2, 2),
('C10', 30.00, '12345678901', 3, 2); [cite: 182, 183, 184, 185, 186]
