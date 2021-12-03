class TripsPending2 {
    TripsPending2(
        this.tripId,
        this.fecha,
        this.hora,
        this.empresa,
        this.agentes,
        this.conductor
    );

    int tripId;
    String fecha;
    String hora;
    String empresa;
    int agentes;
    String conductor;

}

class TripsHistory {
    TripsHistory(
        this.tripId,
        this.fecha,
        this.hora,
        this.empresa,
        this.agentes,
        this.tipo,
        this.conductor
    );

    int tripId;
    String fecha;
    String hora;
    String empresa;
    int agentes;
    String tipo;
    String conductor;
}

class TripsInProgress {
    TripsInProgress(
        this.tripId,
        this.fecha,
        this.hora,
        this.empresa,
        this.agentes,
        this.tipo,
        this.conductor
    );

    int tripId;
    String fecha;
    String hora;
    String empresa;
    int agentes;
    String tipo;
    String conductor;

}

class TripsCompanies{
    TripsCompanies(
        this.trips,
        this.companyId,

    );

    int trips;
    int companyId;


}


class TripsDrivers {
    TripsDrivers(
        this.driverId,
        this.driverDni,
        this.driverPhone,
        this.driverFullname,
        this.driverType,
        this.driverStatus,
        this.driverPassword,
    );

    int driverId;
    String driverDni;
    String driverPhone;
    String driverFullname;
    String driverType;
    bool driverStatus;
    String driverPassword;

}