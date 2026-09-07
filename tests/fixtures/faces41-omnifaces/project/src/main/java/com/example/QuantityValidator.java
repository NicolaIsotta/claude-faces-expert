package com.example;

import jakarta.faces.application.FacesMessage;
import jakarta.faces.component.UIComponent;
import jakarta.faces.context.FacesContext;
import jakarta.faces.validator.FacesValidator;
import jakarta.faces.validator.Validator;
import jakarta.faces.validator.ValidatorException;
import jakarta.inject.Inject;

@FacesValidator(value = "quantityValidator", managed = true)
public class QuantityValidator implements Validator<Integer> {

    @Inject
    private StockService stockService;

    private Integer minimum;
    private Integer maximum;

    @Override
    public void validate(FacesContext context, UIComponent component, Integer value) {
        if (value < minimum || value > maximum) {
            throw new ValidatorException(new FacesMessage("Quantity out of range."));
        }

        if (!stockService.isAvailable(value)) {
            throw new ValidatorException(new FacesMessage("Out of stock."));
        }
    }

    public void setMinimum(Integer minimum) {
        this.minimum = minimum;
    }

    public void setMaximum(Integer maximum) {
        this.maximum = maximum;
    }

}
