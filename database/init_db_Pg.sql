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
    pseudonymous boolean    DEFAULT FALSE,
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
    monk_name    text,
    im           text,
    photo_name   text,

    /* website preferences */
    language     text,
    timezone     text         NOT NULL,

    /* billing info */
    company      text,
    company_url  text,
    address      text,
    vat          text

);
CREATE UNIQUE INDEX users_session_id ON users (session_id);
CREATE UNIQUE INDEX users_login ON users (login);

DROP   TABLE bios;
CREATE TABLE bios
(
    user_id   integer,
    lang      text,
    bio       text
);
CREATE UNIQUE INDEX bios_idx ON bios (user_id, lang);

/* users' rights */
DROP   TABLE rights;
CREATE TABLE rights
(
    right_id    text       NOT NULL,
    conf_id     text       NOT NULL,
    user_id     integer    NOT NULL,

    FOREIGN KEY( user_id  ) REFERENCES users( user_id )
);
CREATE INDEX rights_idx ON rights (conf_id);

/* invoice numer */
DROP   TABLE invoice_num CASCADE;
CREATE TABLE invoice_num
(
    conf_id     text       NOT NULL PRIMARY KEY,
    next_num    integer    NOT NULL
);

/* user's participations to conferences */
DROP   TABLE participations;
CREATE TABLE participations
(
    conf_id     text                      NOT NULL,
    user_id     integer                   NOT NULL,
    registered  boolean    DEFAULT FALSE,
    payment     integer,                  /* notyet, cash, online, cheque, waived */
    tshirt_size text,                     /* S, M, L, XL, XXL */
    nb_family   integer    DEFAULT 0,
    datetime    timestamp without time zone,
    ip          text,

    FOREIGN KEY( user_id  ) REFERENCES users( user_id )
);
CREATE INDEX participations_idx ON participations (conf_id, user_id);

/*** Talks related tables ***/
/* talks */
DROP   TABLE talks CASCADE;
CREATE TABLE talks
(
    talk_id    serial    NOT NULL    PRIMARY KEY,
    conf_id    text      NOT NULL,
    user_id    integer   NOT NULL,

    /* talk info */
    title        text,
    abstract     text,
    url_abstract text,
    url_talk     text,
    duration     integer,
    lightning    boolean DEFAULT false NOT NULL,

    /* for the organisers */
    accepted     boolean DEFAULT false NOT NULL,
    confirmed    boolean DEFAULT false NOT NULL,
    comment      text,

    /* for the schedule */
    room         text,
    datetime     timestamp without time zone,
    track_id     text,

    FOREIGN KEY( user_id  ) REFERENCES users( user_id )
    /* FOREIGN KEY( category_id  ) REFERENCES category( category_id ) */
);
CREATE INDEX talks_idx ON talks ( talk_id, conf_id );

/* events */
DROP   TABLE events CASCADE;
CREATE TABLE events
(
    event_id   serial    NOT NULL    PRIMARY KEY,
    conf_id    text      NOT NULL,
    title      text      NOT NULL,
    abstract   text,
    url_abstract text,
    room       text, 
    duration   integer,
    datetime   timestamp without time zone,
    track_id   text
);
CREATE INDEX events_idx ON events ( event_id, conf_id );

/* tracks */
DROP   TABLE tracks CASCADE;
CREATE TABLE tracks
(   
    track_id    text       NOT NULL,
    conf_id     text       NOT NULL,
    title       text,
    description text
);
CREATE INDEX tracks_idx ON tracks ( track_id, conf_id );

/* prices */
DROP   TABLE prices CASCADE;
CREATE TABLE prices
(
    price_id   serial    NOT NULL    PRIMARY KEY,
    conf_id    text      NOT NULL,
    amount     integer   NOT NULL,
    currency   text      NOT NULL
);

/* orders */
DROP   TABLE orders CASCADE;
CREATE TABLE orders
(
    order_id   serial    NOT NULL    PRIMARY KEY,
    conf_id    text      NOT NULL,
    user_id    integer   NOT NULL,
    datetime   timestamp without time zone NOT NULL,

    /* order info */
    amount     integer   NOT NULL,
    means      text,
    currency   text,
    status     text      NOT NULL,

    FOREIGN KEY( user_id  ) REFERENCES users( user_id )
);

/* invoices */
DROP   TABLE invoices CASCADE;
CREATE TABLE invoices
(
    /* invoice info */
    invoice_id serial    NOT NULL    PRIMARY KEY,
    order_id   integer   NOT NULL,
    datetime   timestamp without time zone NOT NULL,
    invoice_no integer   NOT NULL,

    /* order info */
    amount     integer   NOT NULL,
    means      text,
    currency   text,

    /* user info */
    first_name   text,
    last_name    text,

    /* billing info */
    company      text,
    address      text,
    vat          text,

    FOREIGN KEY( order_id  ) REFERENCES orders( order_id )
);
CREATE UNIQUE INDEX invoices_idx ON invoices ( order_id );

/* multilingual entries */
DROP   TABLE translations;
CREATE TABLE translations
(
    tbl      text NOT NULL,
    col      text NOT NULL,           
    id       text NOT NULL,
    lang     text NOT NULL,
    text     text NOT NULL
);
CREATE UNIQUE INDEX translations_idx ON translations ( tbl, col, id, lang );

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

/* perl mongers groups */
DROP   TABLE pm_groups CASCADE;
CREATE TABLE pm_groups
(
    group_id      serial     NOT NULL  PRIMARY KEY,
    xml_group_id  integer,   /* from the perl_mongers.xml file */
    name          text,
    status        text,
    continent     text,
    country       text,
    state         text
);
CREATE INDEX pm_groups_idx ON pm_groups ( xml_group_id );

