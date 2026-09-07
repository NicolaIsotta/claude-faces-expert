package com.example;

import java.io.Serializable;
import java.util.List;

import jakarta.annotation.PostConstruct;
import jakarta.faces.view.ViewScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;

@Named
@ViewScoped
public class CatalogBean implements Serializable {

    private static final long serialVersionUID = 1L;

    @Inject
    private StatusService statusService;

    private Integer quantity;
    private Integer bulkQuantity;
    private Integer minimumQuantity;
    private Integer maximumQuantity;
    private OrderStatus status;
    private List<OrderStatus> availableStatuses;

    @PostConstruct
    public void init() {
        minimumQuantity = 1;
        maximumQuantity = 100;
        availableStatuses = statusService.listAll();
    }

    public String order() {
        return "confirmation?faces-redirect=true";
    }

    public List<OrderStatus> getAvailableStatuses() {
        return availableStatuses;
    }

    public Integer getMinimumQuantity() {
        return minimumQuantity;
    }

    public Integer getMaximumQuantity() {
        return maximumQuantity;
    }

    public Integer getQuantity() {
        return quantity;
    }

    public void setQuantity(Integer quantity) {
        this.quantity = quantity;
    }

    public Integer getBulkQuantity() {
        return bulkQuantity;
    }

    public void setBulkQuantity(Integer bulkQuantity) {
        this.bulkQuantity = bulkQuantity;
    }

    public OrderStatus getStatus() {
        return status;
    }

    public void setStatus(OrderStatus status) {
        this.status = status;
    }

}
