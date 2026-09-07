package com.example;

import java.io.Serializable;
import java.util.UUID;

import javax.annotation.PostConstruct;
import javax.faces.context.FacesContext;
import javax.faces.view.ViewScoped;
import javax.inject.Inject;
import javax.inject.Named;

@Named
@ViewScoped
public class TicketBean implements Serializable {

    private static final long serialVersionUID = 1L;

    @Inject
    private TicketService ticketService;

    private UUID reference;
    private String subject;

    @PostConstruct
    public void init() {
        if (!FacesContext.getCurrentInstance().isPostback()) {
            reference = ticketService.nextReference();
        }
    }

    public String submit() {
        ticketService.submit(reference, subject);
        return "confirmation?faces-redirect=true";
    }

    public UUID getReference() {
        return reference;
    }

    public void setReference(UUID reference) {
        this.reference = reference;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

}
