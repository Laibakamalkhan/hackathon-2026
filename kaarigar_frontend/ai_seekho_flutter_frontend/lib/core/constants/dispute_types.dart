enum DisputeTypeUi { poorService, noShow, overcharged, other }

extension DisputeTypeUiExtension on DisputeTypeUi {
  String get apiValue {
    switch (this) {
      case DisputeTypeUi.poorService:
        return 'quality';
      case DisputeTypeUi.noShow:
        return 'no_show';
      case DisputeTypeUi.overcharged:
        return 'price';
      case DisputeTypeUi.other:
        return 'quality';
    }
  }

  String get label {
    switch (this) {
      case DisputeTypeUi.poorService:
        return 'Poor service';
      case DisputeTypeUi.noShow:
        return 'No show';
      case DisputeTypeUi.overcharged:
        return 'Overcharged';
      case DisputeTypeUi.other:
        return 'Other';
    }
  }
}
