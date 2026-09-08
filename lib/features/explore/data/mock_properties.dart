import '../../search/domain/property.dart';

const demoProperties = <Property>[
  Property(
    id: 'demo-001',
    title: 'Apartamento ensolarado no centro',
    address: 'Rua dos Andradas',
    streetNumber: '245',
    neighborhood: 'Centro',
    city: 'Porto Alegre',
    state: 'RS',
    description:
        'Apartamento mobiliado, iluminado e pronto para morar, perto de cafes e transporte.',
    price: 1850,
    imagesUrls: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=1200&q=85',
      'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=1200&q=85',
    ],
    maxOccupancy: 2,
    bedrooms: 1,
    bathrooms: 1,
    accommodationType: 'moradia individual',
    petFriendly: true,
  ),
  Property(
    id: 'demo-002',
    title: 'Casa compartilhada com jardim',
    address: 'Rua Miguel Tostes',
    streetNumber: '890',
    neighborhood: 'Rio Branco',
    city: 'Porto Alegre',
    state: 'RS',
    description:
        'Ambiente acolhedor com areas comuns amplas e espaco externo para aproveitar.',
    price: 1250,
    imagesUrls: [
      'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=1200&q=85',
      'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=1200&q=85',
    ],
    maxOccupancy: 4,
    bedrooms: 3,
    bathrooms: 2,
    accommodationType: 'coliving',
    petFriendly: true,
  ),
  Property(
    id: 'demo-003',
    title: 'Studio moderno perto da universidade',
    address: 'Avenida Bento Goncalves',
    streetNumber: '1520',
    neighborhood: 'Partenon',
    city: 'Porto Alegre',
    state: 'RS',
    description:
        'Studio compacto e funcional, com cozinha equipada e excelente localizacao.',
    price: 980,
    imagesUrls: [
      'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=1200&q=85',
      'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=1200&q=85',
    ],
    maxOccupancy: 1,
    bedrooms: 1,
    bathrooms: 1,
    accommodationType: 'moradia individual',
  ),
];
