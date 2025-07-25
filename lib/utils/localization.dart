import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'),
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('de', 'DE'),
    Locale('it', 'IT'),
  ];

  static final Map<String, Map<String, String>> _localizedStrings = {
    'fr': {
      // Search
      'search_city': 'Rechercher une ville...',
      'city_not_found': 'Ville non trouvée.',
      'search_error': 'Erreur lors de la recherche.',
      
      // Location
      'location_permission_denied': 'Permission de localisation refusée.',
      'location_error': 'Erreur de localisation.',
      
      // Dip actions
      'add_this_dip': 'Ajouter ce dip',
      'edit': 'Modifier',
      'delete': 'Supprimer',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      
      // Dip form
      'dip_name': 'Nom du dip',
      'description': 'Description',
      'no_description': 'Aucune description',
      'temperature_felt': 'Température ressentie',
      'rating': 'Note',
      'add_photo': 'Ajouter une photo',
      'take_photo': 'Prendre une photo',
      'choose_gallery': 'Choisir dans la galerie',
      
      // Temperature labels
      'temp_freezing': 'Glaciale',
      'temp_cold': 'Froide',
      'temp_good': 'Bonne',
      'temp_warm': 'Chaude',
      'temp_hot': 'Brûlante',
      
      // Validation
      'name_required': 'Le nom est requis',
      'name_too_short': 'Le nom doit faire au moins 2 caractères',
      
      // Stats
      'total_dips': 'Dips totaux',
      'average_rating': 'Note moyenne',
      'favorite_temperature': 'Température favorite',
      'map_style': 'Style de carte',
    },
    'en': {
      // Search
      'search_city': 'Search for a city...',
      'city_not_found': 'City not found.',
      'search_error': 'Search error.',
      
      // Location
      'location_permission_denied': 'Location permission denied.',
      'location_error': 'Location error.',
      
      // Dip actions
      'add_this_dip': 'Add this dip',
      'edit': 'Edit',
      'delete': 'Delete',
      'save': 'Save',
      'cancel': 'Cancel',
      
      // Dip form
      'dip_name': 'Dip name',
      'description': 'Description',
      'no_description': 'No description',
      'temperature_felt': 'Felt temperature',
      'rating': 'Rating',
      'add_photo': 'Add photo',
      'take_photo': 'Take photo',
      'choose_gallery': 'Choose from gallery',
      
      // Temperature labels
      'temp_freezing': 'Freezing',
      'temp_cold': 'Cold',
      'temp_good': 'Good',
      'temp_warm': 'Warm',
      'temp_hot': 'Hot',
      
      // Validation
      'name_required': 'Name is required',
      'name_too_short': 'Name must be at least 2 characters',
      
      // Stats
      'total_dips': 'Total dips',
      'average_rating': 'Average rating',
      'favorite_temperature': 'Favorite temperature',
      'map_style': 'Map style',
    },
    'es': {
      // Search
      'search_city': 'Buscar una ciudad...',
      'city_not_found': 'Ciudad no encontrada.',
      'search_error': 'Error de búsqueda.',
      
      // Location
      'location_permission_denied': 'Permiso de ubicación denegado.',
      'location_error': 'Error de ubicación.',
      
      // Dip actions
      'add_this_dip': 'Añadir este baño',
      'edit': 'Editar',
      'delete': 'Eliminar',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      
      // Dip form
      'dip_name': 'Nombre del baño',
      'description': 'Descripción',
      'no_description': 'Sin descripción',
      'temperature_felt': 'Temperatura percibida',
      'rating': 'Calificación',
      'add_photo': 'Añadir foto',
      'take_photo': 'Tomar foto',
      'choose_gallery': 'Elegir de galería',
      
      // Temperature labels
      'temp_freezing': 'Helada',
      'temp_cold': 'Fría',
      'temp_good': 'Buena',
      'temp_warm': 'Cálida',
      'temp_hot': 'Caliente',
      
      // Validation
      'name_required': 'El nombre es obligatorio',
      'name_too_short': 'El nombre debe tener al menos 2 caracteres',
      
      // Stats
      'total_dips': 'Baños totales',
      'average_rating': 'Calificación promedio',
      'favorite_temperature': 'Temperatura favorita',
      'map_style': 'Estilo de mapa',
    },
    'de': {
      // Search
      'search_city': 'Stadt suchen...',
      'city_not_found': 'Stadt nicht gefunden.',
      'search_error': 'Suchfehler.',
      
      // Location
      'location_permission_denied': 'Standortberechtigung verweigert.',
      'location_error': 'Standortfehler.',
      
      // Dip actions
      'add_this_dip': 'Dieses Bad hinzufügen',
      'edit': 'Bearbeiten',
      'delete': 'Löschen',
      'save': 'Speichern',
      'cancel': 'Abbrechen',
      
      // Dip form
      'dip_name': 'Name des Bades',
      'description': 'Beschreibung',
      'no_description': 'Keine Beschreibung',
      'temperature_felt': 'Gefühlte Temperatur',
      'rating': 'Bewertung',
      'add_photo': 'Foto hinzufügen',
      'take_photo': 'Foto aufnehmen',
      'choose_gallery': 'Aus Galerie wählen',
      
      // Temperature labels
      'temp_freezing': 'Eisig',
      'temp_cold': 'Kalt',
      'temp_good': 'Gut',
      'temp_warm': 'Warm',
      'temp_hot': 'Heiß',
      
      // Validation
      'name_required': 'Name ist erforderlich',
      'name_too_short': 'Name muss mindestens 2 Zeichen haben',
      
      // Stats
      'total_dips': 'Gesamte Bäder',
      'average_rating': 'Durchschnittsbewertung',
      'favorite_temperature': 'Lieblingstemperatur',
      'map_style': 'Kartenstil',
    },
    'it': {
      // Search
      'search_city': 'Cerca una città...',
      'city_not_found': 'Città non trovata.',
      'search_error': 'Errore di ricerca.',
      
      // Location
      'location_permission_denied': 'Permesso di localizzazione negato.',
      'location_error': 'Errore di localizzazione.',
      
      // Dip actions
      'add_this_dip': 'Aggiungi questo tuffo',
      'edit': 'Modifica',
      'delete': 'Elimina',
      'save': 'Salva',
      'cancel': 'Annulla',
      
      // Dip form
      'dip_name': 'Nome del tuffo',
      'description': 'Descrizione',
      'no_description': 'Nessuna descrizione',
      'temperature_felt': 'Temperatura percepita',
      'rating': 'Valutazione',
      'add_photo': 'Aggiungi foto',
      'take_photo': 'Scatta foto',
      'choose_gallery': 'Scegli dalla galleria',
      
      // Temperature labels
      'temp_freezing': 'Gelida',
      'temp_cold': 'Fredda',
      'temp_good': 'Buona',
      'temp_warm': 'Calda',
      'temp_hot': 'Bollente',
      
      // Validation
      'name_required': 'Il nome è obbligatorio',
      'name_too_short': 'Il nome deve avere almeno 2 caratteri',
      
      // Stats
      'total_dips': 'Tuffi totali',
      'average_rating': 'Valutazione media',
      'favorite_temperature': 'Temperatura preferita',
      'map_style': 'Stile mappa',
    },
  };

  String translate(String key) {
    return _localizedStrings[locale.languageCode]?[key] ?? key;
  }

  // Convenience getters
  String get searchCity => translate('search_city');
  String get cityNotFound => translate('city_not_found');
  String get searchError => translate('search_error');
  String get locationPermissionDenied => translate('location_permission_denied');
  String get locationError => translate('location_error');
  String get addThisDip => translate('add_this_dip');
  String get edit => translate('edit');
  String get delete => translate('delete');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get dipName => translate('dip_name');
  String get description => translate('description');
  String get noDescription => translate('no_description');
  String get temperatureFelt => translate('temperature_felt');
  String get rating => translate('rating');
  String get addPhoto => translate('add_photo');
  String get takePhoto => translate('take_photo');
  String get chooseGallery => translate('choose_gallery');
  String get nameRequired => translate('name_required');
  String get nameTooShort => translate('name_too_short');
  String get totalDips => translate('total_dips');
  String get averageRating => translate('average_rating');
  String get favoriteTemperature => translate('favorite_temperature');
  String get mapStyle => translate('map_style');

  // Temperature labels
  List<String> get temperatureLabels => [
    translate('temp_freezing'),
    translate('temp_cold'),
    translate('temp_good'),
    translate('temp_warm'),
    translate('temp_hot'),
  ];
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
