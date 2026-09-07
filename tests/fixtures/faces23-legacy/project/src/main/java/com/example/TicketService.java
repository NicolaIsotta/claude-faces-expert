package com.example;

import java.util.UUID;

import javax.enterprise.context.ApplicationScoped;

@ApplicationScoped
public class TicketService {

    public UUID nextReference() {
        return UUID.randomUUID();
    }

    public void submit(UUID reference, String subject) {
        // Persists the ticket.
    }

}
