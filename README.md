# Quiz-booking-system-architecture
This repo has Architecture daigram for Quiz booking system


# USED Architectural patterns

# BFF in Conjunction with Event Sourcing Pattern BFF

The BFF pattern introduces a dedicated service for each frontend client (e.g., web app, mobile app). This service acts as a facade for the backend, offering the following benefits:
Simplified Frontend Development: The frontend only interacts with a single, well-defined API provided by the BFF. This reduces complexity and allows developers to focus on the user interface.

Tailored Data Presentation: The BFF can aggregate data from multiple backend services and present it in a format optimized for the specific client. This eliminates data duplication and improves the user experience.

Enhanced Security: The BFF can act as a gatekeeper, filtering data and exposing only what's necessary for the client. Sensitive data from backend services can be hidden from the frontend.


# EVENT Sourcing Pattern

The Event Sourcing pattern is a data persistence approach that focuses on storing a sequence of events that represent all the changes to an application's data. It's a powerful alternative to the traditional method of storing the current state of the data.

Here's a breakdown of the core concepts: Traditional Data Persistence:

In the traditional approach, data is stored in a database (relational or NoSQL) as its current state.

Whenever the data changes, the updated state is saved in the database, overwriting the previous version.

 This method can make it difficult to track the history of changes & Replay events to recreate past states.

# Event Sourcing:

Event Sourcing flips the script. Instead of storing the current state, it stores a sequence of events that represent all the changes that have happened to the data.

# Each event is a self-contained unit containing details about the change, like:

Timestamp of the event,
Type of event (e.g., "ItemAdded", "ItemUpdated"),
Data associated with the event (e.g., new item details for "ItemAdded"),
Events are typically stored in an append-only database called an event store.


# Daigram links

https://structurizr.com/share/93621

https://structurizr.com/share/93621/diagrams
