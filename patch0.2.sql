CREATE TABLE transport_lines (
	
    line_id varchar(10) PRIMARY KEY,
    line_city varchar(20) REFERENCES cities(city_name),
	line_company varchar(30) REFERENCES companies(line_company)

);

CREATE TABLE line_tickets (

    line_id varchar(10) PRIMARY KEY REFERENCES transport_lines(line_id),
    ticket_type int REFERENCES ticket_types(ticketType_id)

);
