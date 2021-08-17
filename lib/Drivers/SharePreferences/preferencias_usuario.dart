import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {

  static final PreferenciasUsuario _instancia = new PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    return _instancia;
  }

  PreferenciasUsuario._internal();

  SharedPreferences _prefs;

  initPrefs() async {
    this._prefs = await SharedPreferences.getInstance();
  }



  // GET y SET del nombreUsuario
  get nombreUsuario {
    return _prefs.getString('nombreUsuario') ?? '';
  }

  set nombreUsuario( String value ) {
    _prefs.setString('nombreUsuario', value);
  }


    // GET y SET del nombreUsuario
  get nombreUsuarioFull {
    return _prefs.getString('nombreUsuarioFull') ?? '';
  }

  set nombreUsuarioFull( String value ) {
    _prefs.setString('nombreUsuarioFull', value);
  }

   // GET y SET del nombreUsuario
  get emailUsuario {
    return _prefs.getString('emailUsuario') ?? '';
  }

  set emailUsuario( String value ) {
    _prefs.setString('emailUsuario', value);
  }


     // GET y SET del tripId
  get tripId {
    return _prefs.getString('tripId') ?? '';
  }

  set tripId( String value ) {
    _prefs.setString('tripId', value);
  }

       // GET y SET del tripId
  get tripId2 {
    return _prefs.getString('tripId') ?? '';
  }

  set tripId2( String value ) {
    _prefs.setString('tripId', value);
  }

       // GET y SET del tripHours
  get tripHours {
    return _prefs.getString('tripHours') ?? '';
  }

  set tripHours( DateTime value ) {
    _prefs.setString('tripHours', value.toString());
  }

         // GET y SET del salida
  get companyId {
    return _prefs.getString('companyId') ?? '';
  }

  set companyId( String value ) {
    _prefs.setString('companyId', value.toString());
  }

    get agentEmployeeId {
    return _prefs.getString('agentEmployeeId') ?? '';
  }

  set agentEmployeeId( String value ) {
    _prefs.setString('agentEmployeeId', value.toString());
  }


         // GET y SET del salida
  get passwordUser {
    return _prefs.getString('passwordUser') ?? '';
  }

  set passwordUser( String value ) {
    _prefs.setString('passwordUser', value.toString());
  }


           // GET y SET del salida
  get driverIdx {
    return _prefs.getString('driverIdx') ?? '';
  }

  set driverIdx( String value ) {
    _prefs.setString('driverIdx', value.toString());
  }

            // GET y SET del salida
  get nameSalida {
    return _prefs.getString('nameSalida') ?? '';
  }

  set nameSalida( String value ) {
    _prefs.setString('nameSalida', value.toString());
  }


             // GET y SET de tokenIdMobile
  get tokenIdMobile {
    return _prefs.getString('tokenIdMobile') ?? '';
  }

  set tokenIdMobile( String value ) {
    _prefs.setString('tokenIdMobile', value);
  }

               // GET y SET de tokenIdMobile
  get phone {
    return _prefs.getString('phone') ?? '';
  }

  set phone( String value ) {
    _prefs.setString('phone', value);
  }


                 // GET y SET de vehiculo
  get vehiculo {
    return _prefs.getString('vehiculo') ?? '';
  }

  set vehiculo( String value ) {
    _prefs.setString('vehiculo', value);
  }



  get companyPrueba{
    return _prefs.getString('companyPrueba') ?? '';
  }

  set companyPrueba( String value ) {
    _prefs.setString('companyPrueba', value.toString());
  }


           // GET y SET del salida
  get companyIdAgent {
    return _prefs.getString('companyIdAgent') ?? '';
  }

  set companyIdAgent( String value ) {
    _prefs.setString('companyIdAgent', value.toString());
  }

  removeIdCompanyAndVehicle(){
    _prefs.remove('companyId');
    _prefs.remove('vehiculo ');
    _prefs.remove('companyPrueba');
  }
  remove(){
    _prefs.remove('nombreUsuario');
    _prefs.remove('passwordUser');
  }


  
}


