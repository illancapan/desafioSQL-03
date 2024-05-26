-- Active: 1716506184190@@127.0.0.1@5432@desafio3_igor_llancapan_123
--CREATE DATABASE desafio3_igor_llancapan_123

-- crear la tabla de usuarios
CREATE TABLE usuarios (
    id                  SERIAL          PRIMARY KEY,
    email               VARCHAR(255)    NOT NULL,
    nombre              VARCHAR(100)    NOT NULL,
    apellido            VARCHAR(100)    NOT NULL,
    rol                 VARCHAR(50)     NOT NULL
);

-- insertar usuarios en la tabla de usuarios
INSERT INTO usuarios (email, nombre, apellido, rol) VALUES
('admin@example.com', 'Admin', 'User', 'administrador'),
('user1@example.com', 'User1', 'LastName1', 'usuario'),
('user2@example.com', 'User2', 'LastName2', 'usuario'),
('user3@example.com', 'User3', 'LastName3', 'usuario'),
('user4@example.com', 'User4', 'LastName4', 'usuario');

CREATE TABLE posts (
    id                  BIGINT          PRIMARY KEY,
    fecha_creacion      TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
    destacado           BOOLEAN,
    usuario_id          BIGINT,
    titulo              VARCHAR(255)    NOT NULL,
    contenido           TEXT            NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

INSERT INTO posts (id, fecha_creacion, fecha_actualizacion, destacado, usuario_id, titulo, contenido) VALUES
(1, '2024-05-26 10:00:00', '2024-05-26 10:00:00', true, 1, 'Título Post 1', 'Contenido del Post 1'),
(2, '2024-05-26 11:00:00', '2024-05-26 11:00:00', false, 1, 'Título Post 2', 'Contenido del Post 2'),
(3, '2024-05-26 12:00:00', '2024-05-26 12:00:00', false, 2, 'Título Post 3', 'Contenido del Post 3'),
(4, '2024-05-26 13:00:00', '2024-05-26 13:00:00', true, 3, 'Título Post 4', 'Contenido del Post 4'),
(5, '2024-05-26 14:00:00', '2024-05-26 14:00:00', false, NULL, 'Título Post 5', 'Contenido del Post 5');


CREATE TABLE comentarios (
    id                  BIGINT          PRIMARY KEY,
    fecha_creacion      TIMESTAMP,
    usuario_id          BIGINT,
    post_id             BIGINT,
    comentario          TEXT            NOT NULL,
    FOREIGN KEY (usuario_id)    REFERENCES usuarios(id),
    FOREIGN KEY (post_id)       REFERENCES posts(id)
);

INSERT INTO comentarios (id, fecha_creacion, usuario_id, post_id, comentario) VALUES
(1, '2024-05-26 15:00:00', 1, 1, 'Comentario 1 para Post 1'),
(2, '2024-05-26 15:10:00', 2, 1, 'Comentario 2 para Post 1'),
(3, '2024-05-26 15:20:00', 3, 1, 'Comentario 3 para Post 1'),
(4, '2024-05-26 15:30:00', 1, 2, 'Comentario 1 para Post 2'),
(5, '2024-05-26 15:40:00', 2, 2, 'Comentario 2 para Post 2');

-- 2. Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas: nombre y email del usuario junto al título y contenido del post.
SELECT u.nombre, u.email, p.titulo, p.contenido
FROM usuarios u
JOIN posts p ON u.id = p.usuario_id;

-- 3. Muestra el id, título y contenido de los posts de los administradores.
-- a. El administrador puede ser cualquier id.

SELECT p.id, p.titulo, p.contenido
FROM posts p
JOIN usuarios u ON p.usuario_id = u.id
WHERE u.rol = 'administrador';

-- 4. Cuenta la cantidad de posts de cada usuario.
-- a. La tabla resultante debe mostrar el id e email del usuario junto con la
-- cantidad de posts de cada usuario.

SELECT u.id, u.email, COUNT(p.id) AS cantidad_de_posts
FROM usuarios u
LEFT JOIN posts p ON u.id = p.usuario_id
GROUP BY u.id, u.email;

-- 5. Muestra el email del usuario que ha creado más posts.
-- a. Aquí la tabla resultante tiene un único registro y muestra solo el email.

SELECT u.email
FROM usuarios u
JOIN posts p ON u.id = p.usuario_id 
GROUP BY u.email 
ORDER BY COUNT(p.id) DESC 
LIMIT 1; -- se puede limitar a 1 o mas para obtener la informacion requerida

-- 6. Muestra la fecha del último post de cada usuario.

SELECT u.id, u.nombre, u.email, MAX(p.fecha_creacion) AS fecha_ultimo_post
FROM usuarios u
JOIN posts p ON u.id = p.usuario_id
GROUP BY u.id, u.email;

-- 7. Muestra el título y contenido del post (artículo) con más comentarios.

SELECT p.titulo, p.contenido
FROM posts p
JOIN comentarios c ON p.id = c.post_id
GROUP BY p.id
ORDER BY COUNT(c.id) DESC
LIMIT 1;

-- 8. Muestra en una tabla el título de cada post, el contenido de cada post y el contenido
-- de cada comentario asociado a los posts mostrados, junto con el email del usuario
-- que lo escribió.

SELECT p.titulo AS titulo_post, p.contenido AS contenido_post, c.comentario AS comentario_posts, u.email
FROM posts p
JOIN comentarios c ON p.id = c.post_id
JOIN usuarios u ON c.usuario_id = u.id;

-- 9. Muestra el contenido del último comentario de cada usuario.

SELECT c.fecha_creacion, c.comentario, u.id, u.nombre
FROM usuarios u
JOIN comentarios c ON u.id = c.usuario_id
LEFT JOIN comentarios c2 ON c.usuario_id = c2.usuario_id AND c.fecha_creacion < c2.fecha_creacion
WHERE NOT EXISTS (
    SELECT 1
    FROM comentarios c3
    WHERE c3.usuario_id = c.usuario_id AND c3.fecha_creacion > c.fecha_creacion
)
ORDER BY u.id ASC;

-- 10. Muestra los emails de los usuarios que no han escrito ningún comentario.
SELECT u.email
FROM usuarios u
LEFT JOIN comentarios c ON u.id = c.usuario_id
GROUP BY u.id
HAVING COUNT(c.id) = 0;

