/*** users' related tables ***/

/* users */
DROP   TABLE users CASCADE;
CREATE TABLE users
(
    user_id     serial     NOT NULL  PRIMARY KEY,
    login       text       NOT NULL,
    passwd      text       NOT NULL,
    session_id  text,

    /* personal information */
    civility     integer,   /* handled in translations */
    first_name   text,
    last_name    text,
    nick_name    text,
    pseudonymous text,
    country      text       NOT NULL,
    town         text,

    /* online indentity */
    web_page     text,
    pm_group     text,
    pm_group_url text,
    email        text                       NOT NULL,
    email_hide   boolean      DEFAULT TRUE  NOT NULL,
    gpg_pub_key  text,
    pause_id     text,
    monk_id      text,
    icq          text,
    bio          integer,    /* handled in translations? */

    /* website preferences */
    language     text,
    timezone     text         DEFAULT 'Europe/Paris'   NOT NULL
);
CREATE INDEX users_session_id ON users (session_id);

/* users' rights */
DROP   TABLE rights;
CREATE TABLE rights
(
    name        text       NOT NULL,
    conf_id     text       NOT NULL,
    user_id     integer    NOT NULL,

    FOREIGN KEY( user_id  ) REFERENCES users( user_id )
);
CREATE INDEX rights_idx ON rights (conf_id);

/* user's participations to conferences */
DROP   TABLE participations;
CREATE TABLE participations
(
    conf_id     text,
    user_id     integer,
    registered  boolean,
    payment     integer, /* notyet, cash, online, cheque, waived */
    tshirt_size integer,
    nb_family   integer,

    FOREIGN KEY( user_id  ) REFERENCES users( user_id )
);
CREATE INDEX participations_idx ON rights (conf_id);

/*** Talks related tables ***/
/* talks */
DROP   TABLE talks;
CREATE TABLE talks
(
    talk_id    integer,
    conf_id    text,
    user_id    integer,

    /* talk info */
    title        text,
    abstract     text,
    url_abstract text,
    url_talk     text,
    duration     integer NOT NULL,
    lightning    boolean DEFAULT false NOT NULL,

    /* for the organisers */
    accepted     boolean DEFAULT false NOT NULL,
    confirmed    boolean DEFAULT false NOT NULL,
    comment      text,

    /* for the schedule */
    room         text,
    given        timestamp without time zone,
    /* category_id  integer, */
  

    FOREIGN KEY( user_id  ) REFERENCES users( user_id )
    /* FOREIGN KEY( category_id  ) REFERENCES category( category_id ) */
);
CREATE INDEX talks_idx ON talks ( conf_id );


/* multilingual entries */
DROP   TABLE translations;
CREATE TABLE translations
(
    tbl      text,
    col      text,           
    id       integer,
    lang     text,
    text     text
);
CREATE INDEX translations_idx ON translations ( tbl, col, id );

/* conference news */
DROP   TABLE news;
CREATE TABLE news
(
    conf_id  text,
    lang     text,
    date     date,
    text     text
);
CREATE INDEX news_idx ON news ( conf_id, lang );
