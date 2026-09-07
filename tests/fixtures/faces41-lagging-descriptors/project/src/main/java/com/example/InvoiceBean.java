package com.example;

import java.io.Serializable;
import java.math.BigDecimal;

import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;

@Named
@ViewScoped
public class InvoiceBean implements Serializable {

    private static final long serialVersionUID = 1L;

    @Inject
    private InvoiceService invoiceService;

    private Long id;
    private BigDecimal amount;

    public void load() {
        amount = invoiceService.findAmount(id);
    }

    public String save() {
        invoiceService.save(id, amount);
        return "invoices?faces-redirect=true";
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

}
