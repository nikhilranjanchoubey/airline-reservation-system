<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer currentStep = (Integer) request.getAttribute("stepNumber");
    if (currentStep == null) currentStep = 1;
%>
<div class="skytech-stepper-container">
    <div class="container">
        <div class="skytech-stepper">
            <div class="skytech-step-item <%= (currentStep == 1) ? "active" : ((currentStep > 1) ? "completed" : "") %>">
                <div class="skytech-step-circle"><%= (currentStep > 1) ? "<i class='bi bi-check-lg'></i>" : "1" %></div>
                <div class="skytech-step-label">Flight Selected</div>
            </div>
            <div class="skytech-step-item <%= (currentStep == 2) ? "active" : ((currentStep > 2) ? "completed" : "") %>">
                <div class="skytech-step-circle"><%= (currentStep > 2) ? "<i class='bi bi-check-lg'></i>" : "2" %></div>
                <div class="skytech-step-label">Passenger Details</div>
            </div>
            <div class="skytech-step-item <%= (currentStep == 3) ? "active" : ((currentStep > 3) ? "completed" : "") %>">
                <div class="skytech-step-circle"><%= (currentStep > 3) ? "<i class='bi bi-check-lg'></i>" : "3" %></div>
                <div class="skytech-step-label">Seat Selection</div>
            </div>
            <div class="skytech-step-item <%= (currentStep == 4) ? "active" : ((currentStep > 4) ? "completed" : "") %>">
                <div class="skytech-step-circle"><%= (currentStep > 4) ? "<i class='bi bi-check-lg'></i>" : "4" %></div>
                <div class="skytech-step-label">Review Booking</div>
            </div>
            <div class="skytech-step-item <%= (currentStep == 5) ? "active" : ((currentStep > 5) ? "completed" : "") %>">
                <div class="skytech-step-circle"><%= (currentStep > 5) ? "<i class='bi bi-check-lg'></i>" : "5" %></div>
                <div class="skytech-step-label">Payment</div>
            </div>
            <div class="skytech-step-item <%= (currentStep == 6) ? "active" : "" %>">
                <div class="skytech-step-circle">6</div>
                <div class="skytech-step-label">Confirmation</div>
            </div>
        </div>
    </div>
</div>
