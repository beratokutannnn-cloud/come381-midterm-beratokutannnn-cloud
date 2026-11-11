CREATE TABLE membership_plan (
    plan_id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    plan_name       varchar(50),
    monthly_price   numeric(8,2),
    duration_months smallint
);

CREATE TABLE trainer (
    trainer_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name  varchar(100),
    specialty  varchar(50)
);

CREATE TABLE member (
    member_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    plan_id   integer REFERENCES membership_plan(plan_id),
    full_name varchar(100),
    email     varchar(150),
    join_date date
);

CREATE TABLE fitness_class (
    class_id   integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    trainer_id integer REFERENCES trainer(trainer_id),
    class_name varchar(100),
    start_time timestamp,
    capacity   smallint
);

-- M:N: bir üye birçok derse, bir derse birçok üye rezervasyon yapabilir
CREATE TABLE class_booking (
    member_id    integer REFERENCES member(member_id),
    class_id     integer REFERENCES fitness_class(class_id),
    booking_date date,
    attended     boolean,
    PRIMARY KEY (member_id, class_id)
);