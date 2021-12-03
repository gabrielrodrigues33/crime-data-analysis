CREATE TABLE tempo (
    tempo_key SERIAL PRIMARY KEY,
    mes_numero INT,
    mes_nome VARCHAR(255),
    ano INT
);

CREATE TABLE IF NOT EXISTS lugar (
    lugar_key SERIAL PRIMARY KEY NOT NULL,
    latitude integer,
    longitude integer,
    cidade character varying(50),
    logradouro character varying(100),
    numero_logradouro integer
);

CREATE TABLE pessoa AS (
    pessoa_key SERIAL PRIMARY KEY,
    tipo_envolvimento VARCHAR,
    sexo CHAR,
    idade INTEGER,
    cor VARCHAR (20),
    profissao VARCHAR (100),
    grau_instrucao VARCHAR(100)
);

CREATE TABLE delegacia (
    delegacia_key SERIAL PRIMARY KEY,
    nome_departamento varchar(255),
    nome_seccional varchar(255),
    nome_delegacia varchar(255)
);

CREATE TABLE ocorrencias (
    tempo_ocorrencia_key INTEGER FOREIGN KEY (fk_ocorrencias_tempo_ocorrencia_key) REFERENCES tempo (tempo_key),
    tempo_registro_key INTEGER FOREIGN KEY (fk_ocorrencias_tempo_registro_key) REFERENCES tempo (tempo_key),
    delegacia_ocorrencia_key INTEGER FOREIGN KEY (fk_ocorrencias_delegacia_ocorrencia_key) REFERENCES delegacia (delegacia_key),
    delegacia_registro_key INTEGER FOREIGN KEY (fk_ocorrencias_delegacia_registro_key) REFERENCES delegacia (delegacia_key),
    lugar_key INTEGER FOREIGN KEY (fk_ocorrencias_lugar_key) REFERENCES lugar (lugar_key),
    pessoa_key INTEGER FOREIGN KEY (fk_ocorrencias_pessoa_key) REFERENCES pessoa (pessoa_key),

    num_bo VARCHAR(20),
    flag_status VARCHAR(20),
    rubrica VARCHAR(256),
    conduta VARCHAR(256),
    hora_ocorencia VARCHAR(8),
);

CREATE TABLE ocorrencias_agregada (
    tempo_ocorrencia_key INTEGER FOREIGN KEY (fk_ocorrencias_agregada_tempo_ocorrencia_key) REFERENCES tempo (tempo_key),
    flag_status VARCHAR(20),
    rubrica VARCHAR(256),
    conduta VARCHAR(256),
    quantidade_ocorrencias INTEGER
);