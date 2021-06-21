// To parse this JSON data, do
//
//     final countNotifications = countNotificationsFromJson(jsonString);


class CountNotifications {
    CountNotifications(
        this.total,
        this.tripsCreated,
        this.tripsInProgress,
    );

    int total;
    int tripsCreated;
    int tripsInProgress;
}
