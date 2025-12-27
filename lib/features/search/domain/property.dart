class Property {
  final String id;
  final String title;           // titulo do imóvel
  final String address;         // endereço
  final String streetNumber;    // número da rua
  final String neighborhood;    // bairro
  final String city;            // cidade
  final String state;           // estado (ex: RS)
  final String? description;    // descrição
  final double price;           // preço mensal
  final List<String> imagesUrls; // URLs das imagens
  final int maxOccupancy;       // ocupância máxima
  final int bedrooms;           // número de quartos
  final int bathrooms;          // número de banheiros
  final String accommodationType; // tipo: "coliving" ou "moradia individual"
  final bool petFriendly;       // pet friendly
  final bool favorito;

  const Property({
    required this.id,
    required this.title,
    required this.address,
    required this.streetNumber,
    required this.neighborhood,
    required this.city,
    required this.state,
    this.description,
    required this.price,
    required this.imagesUrls,
    required this.maxOccupancy,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.accommodationType = 'moradia individual',
    this.petFriendly = false,
    this.favorito = false,
  });

  Property copyWith({bool? favorito}) =>
      Property(
        id: id,
        title: title,
        address: address,
        streetNumber: streetNumber,
        neighborhood: neighborhood,
        city: city,
        state: state,
        description: description,
        price: price,
        imagesUrls: imagesUrls,
        maxOccupancy: maxOccupancy,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        accommodationType: accommodationType,
        petFriendly: petFriendly,
        favorito: favorito ?? this.favorito,
      );
}
