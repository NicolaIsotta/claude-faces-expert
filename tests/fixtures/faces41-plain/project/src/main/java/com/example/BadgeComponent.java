package com.example;

import java.io.IOException;

import jakarta.faces.component.FacesComponent;
import jakarta.faces.component.UIComponentBase;
import jakarta.faces.context.FacesContext;
import jakarta.faces.context.ResponseWriter;

@FacesComponent(createTag = true, tagName = "badge", value = "com.example.Badge",
    namespace = "http://xmlns.jcp.org/jsf/component")
public class BadgeComponent extends UIComponentBase {

    @Override
    public String getFamily() {
        return "com.example.Badge";
    }

    @Override
    public void encodeBegin(FacesContext context) throws IOException {
        ResponseWriter writer = context.getResponseWriter();
        writer.startElement("span", this);
        writer.writeAttribute("class", "badge", null);
        writer.writeText(getAttributes().get("value"), this, "value");
        writer.endElement("span");
    }

}
