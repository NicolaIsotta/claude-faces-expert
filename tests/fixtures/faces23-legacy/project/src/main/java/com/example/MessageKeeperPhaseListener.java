package com.example;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.faces.event.PhaseEvent;
import javax.faces.event.PhaseId;
import javax.faces.event.PhaseListener;

public class MessageKeeperPhaseListener implements PhaseListener {

    private static final long serialVersionUID = 1L;

    private static final String SESSION_KEY = "com.example.keptMessages";

    @Override
    public PhaseId getPhaseId() {
        return PhaseId.ANY_PHASE;
    }

    @Override
    public void beforePhase(PhaseEvent event) {
        if (event.getPhaseId() != PhaseId.RENDER_RESPONSE) {
            return;
        }

        FacesContext context = event.getFacesContext();
        Map<String, Object> session = context.getExternalContext().getSessionMap();
        List<FacesMessage> kept = (List<FacesMessage>) session.remove(SESSION_KEY);

        if (kept != null) {
            for (FacesMessage message : kept) {
                context.addMessage(null, message);
            }
        }
    }

    @Override
    public void afterPhase(PhaseEvent event) {
        if (event.getPhaseId() != PhaseId.INVOKE_APPLICATION) {
            return;
        }

        FacesContext context = event.getFacesContext();

        if (!context.getExternalContext().isResponseCommitted()) {
            List<FacesMessage> kept = new ArrayList<>();

            for (Iterator<FacesMessage> iterator = context.getMessages(); iterator.hasNext();) {
                kept.add(iterator.next());
                iterator.remove();
            }

            if (!kept.isEmpty()) {
                context.getExternalContext().getSessionMap().put(SESSION_KEY, kept);
            }
        }
    }

}
