CREATE TABLE transport_lines (
    line_id varchar(10),
    line_city varchar(20),
    line_company varchar(30),
    PRIMARY KEY (line_id, line_city),
    FOREIGN KEY (line_city) REFERENCES cities(city_name),
    FOREIGN KEY (line_company) REFERENCES companies(line_company)
);

CREATE TABLE line_tickets (
    line_id varchar(10),
    ticket_type int,
    PRIMARY KEY (line_id, ticket_type),
    FOREIGN KEY (line_id) REFERENCES transport_lines(line_id),
    FOREIGN KEY (ticket_type) REFERENCES ticket_types(ticketType_id)
);
