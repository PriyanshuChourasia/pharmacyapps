import 'dart:math';

import 'package:shared_models/shared_models.dart';

/// In-memory demo catalog: 8 categories and ~30 realistic Indian-market
/// medicines. Every call resolves with a 200–400 ms artificial delay so the
/// UI's shimmer states are visible. No network access, ever.
///
/// Asset paths are plain strings fed in here, so feature widgets never
/// hard-code the app's asset paths.
class DemoCatalogDataSource {
  static const int _minDelayMs = 200;
  static const int _maxDelayMs = 400;

  final Random _random = Random();

  Future<T> _withDelay<T>(T Function() value) async {
    await Future<void>.delayed(
      Duration(
        milliseconds:
            _minDelayMs + _random.nextInt(_maxDelayMs - _minDelayMs + 1),
      ),
    );
    return value();
  }

  static const List<Category> _categories = [
    Category(
      id: 'pain_relief',
      name: 'Pain Relief',
      imageAsset: 'assets/images/categories/pain_relief.jpg',
      iconKey: 'pain',
    ),
    Category(
      id: 'cold_flu',
      name: 'Cold & Flu',
      imageAsset: 'assets/images/categories/cold_flu.jpg',
      iconKey: 'cold',
    ),
    Category(
      id: 'diabetes',
      name: 'Diabetes',
      imageAsset: 'assets/images/categories/diabetes.jpg',
      iconKey: 'diabetes',
    ),
    Category(
      id: 'vitamins',
      name: 'Vitamins & Supplements',
      imageAsset: 'assets/images/categories/vitamins.jpg',
      iconKey: 'vitamin',
    ),
    Category(
      id: 'skin_care',
      name: 'Skin Care',
      imageAsset: 'assets/images/categories/skin_care.jpg',
      iconKey: 'skin',
    ),
    Category(
      id: 'digestive_health',
      name: 'Digestive Health',
      imageAsset: 'assets/images/categories/digestive_health.jpg',
      iconKey: 'digestive',
    ),
    Category(
      id: 'heart_care',
      name: 'Heart Care',
      imageAsset: 'assets/images/categories/heart_care.jpg',
      iconKey: 'heart',
    ),
    Category(
      id: 'baby_care',
      name: 'Baby Care',
      imageAsset: 'assets/images/categories/baby_care.jpg',
      iconKey: 'baby',
    ),
  ];

  static const String _storeBelow30 =
      'Store below 30°C in a dry place. Keep out of reach of children.';

  // Built via `_med(...)`, so `final` rather than `const`.
  static final List<Product> _products = [
    // ---- Pain Relief ----
    _med(
      id: 'dolo-650',
      name: 'Dolo 650',
      generic: 'Paracetamol',
      salt: 'Paracetamol 650mg',
      maker: 'Micro Labs',
      cat: 'pain_relief',
      pack: 'Strip of 15 tablets',
      mrp: 3850,
      price: 3450,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'Fast-acting tablet for fever, headache, body pain and toothache.',
      uses: ['Fever', 'Headache and body pain'],
      effects: ['Nausea', 'Skin rash (rare)'],
    ),
    _med(
      id: 'crocin-advance',
      name: 'Crocin Advance',
      generic: 'Paracetamol',
      salt: 'Paracetamol 500mg',
      maker: 'GSK',
      cat: 'pain_relief',
      pack: 'Strip of 15 tablets',
      mrp: 3200,
      price: 2950,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'Quick-relief paracetamol tablet for everyday pain and fever.',
      uses: ['Fever', 'Mild to moderate pain'],
      effects: ['Drowsiness', 'Upset stomach'],
    ),
    _med(
      id: 'calpol-500',
      name: 'Calpol 500',
      generic: 'Paracetamol',
      salt: 'Paracetamol 500mg',
      maker: 'GSK',
      cat: 'pain_relief',
      pack: 'Strip of 15 tablets',
      mrp: 3050,
      price: 2800,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'Gentle-on-stomach paracetamol for pain and fever relief.',
      uses: ['Fever', 'Headache'],
      effects: ['Nausea', 'Allergic reaction (rare)'],
    ),
    _med(
      id: 'volini-gel',
      name: 'Volini Pain Relief Gel',
      generic: 'Diclofenac topical',
      salt: 'Diclofenac Diethylamine 1.16% w/w',
      maker: 'Sun Pharma',
      cat: 'pain_relief',
      pack: 'Tube of 30 g',
      mrp: 16500,
      price: 14900,
      img: 'assets/images/products/cream_tube.jpg',
      desc: 'Topical gel that relieves muscular pain and joint stiffness.',
      uses: ['Muscle pain', 'Joint stiffness'],
      effects: ['Skin irritation', 'Contact dermatitis'],
    ),

    // ---- Cold & Flu ----
    _med(
      id: 'cetzine-10',
      name: 'Cetzine 10',
      generic: 'Cetirizine',
      salt: 'Cetirizine Hydrochloride 10mg',
      maker: 'Dr Reddy\u2019s',
      cat: 'cold_flu',
      pack: 'Strip of 10 tablets',
      mrp: 1350,
      price: 1200,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'Antiallergic tablet that controls sneezing, runny nose and itching.',
      uses: ['Allergic rhinitis', 'Watery eyes'],
      effects: ['Drowsiness', 'Dry mouth'],
    ),
    _med(
      id: 'allegra-120',
      name: 'Allegra 120',
      generic: 'Fexofenadine',
      salt: 'Fexofenadine Hydrochloride 120mg',
      maker: 'Sanofi',
      cat: 'cold_flu',
      pack: 'Strip of 10 tablets',
      mrp: 2150,
      price: 1950,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'Non-drowsy allergy relief for sneezing, itching and congestion.',
      uses: ['Seasonal allergies', 'Hives'],
      effects: ['Headache', 'Back pain'],
    ),
    _med(
      id: 'benadryl-cough-syrup',
      name: 'Benadryl Cough Syrup',
      generic: 'Diphenhydramine',
      salt: 'Diphenhydramine 14mg/5ml',
      maker: 'Johnson & Johnson',
      cat: 'cold_flu',
      pack: 'Bottle of 150 ml',
      mrp: 14500,
      price: 13500,
      img: 'assets/images/products/syrup_bottle.jpg',
      desc: 'Soothing syrup for dry cough and throat irritation.',
      uses: ['Dry cough', 'Sore throat'],
      effects: ['Drowsiness', 'Blurred vision'],
    ),
    _med(
      id: 'vicks-vaporub',
      name: 'Vicks VapoRub',
      generic: 'Menthol topical',
      salt: 'Menthol 2.6% + Camphor 5.3%',
      maker: 'P&G',
      cat: 'cold_flu',
      pack: 'Jar of 50 ml',
      mrp: 14500,
      price: 13000,
      img: 'assets/images/products/cream_tube.jpg',
      desc: 'Topical rub that relieves nasal congestion and body aches.',
      uses: ['Nasal congestion', 'Muscle aches'],
      effects: ['Skin irritation', 'Burning sensation'],
    ),

    // ---- Diabetes ----
    _med(
      id: 'glycomet-500',
      name: 'Glycomet 500',
      generic: 'Metformin',
      salt: 'Metformin Hydrochloride 500mg',
      maker: 'USV',
      cat: 'diabetes',
      pack: 'Strip of 20 tablets',
      mrp: 5200,
      price: 4600,
      rx: true,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'First-line medicine to control blood sugar in type 2 diabetes.',
      uses: ['Type 2 diabetes', 'Blood sugar control'],
      effects: ['Nausea', 'Loose motions'],
    ),
    _med(
      id: 'januvia-100',
      name: 'Januvia 100',
      generic: 'Sitagliptin',
      salt: 'Sitagliptin 100mg',
      maker: 'MSD',
      cat: 'diabetes',
      pack: 'Strip of 10 tablets',
      mrp: 17500,
      price: 16000,
      rx: true,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'DPP-4 inhibitor that lowers blood sugar after meals.',
      uses: ['Type 2 diabetes', 'Adjunct to diet and exercise'],
      effects: ['Headache', 'Upper respiratory infection'],
    ),
    _med(
      id: 'istamet-50-500',
      name: 'Istamet 50/500',
      generic: 'Sitagliptin + Metformin',
      salt: 'Sitagliptin 50mg + Metformin 500mg',
      maker: 'MSD',
      cat: 'diabetes',
      pack: 'Strip of 15 tablets',
      mrp: 22500,
      price: 20800,
      rx: true,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'Combination tablet for better blood-sugar control in type 2 diabetes.',
      uses: ['Type 2 diabetes', 'When metformin alone is not enough'],
      effects: ['Nausea', 'Diarrhoea'],
    ),

    // ---- Vitamins & Supplements ----
    _med(
      id: 'becosules',
      name: 'Becosules',
      generic: 'B-Complex',
      salt: 'Vitamin B-Complex + Vitamin C',
      maker: 'Pfizer',
      cat: 'vitamins',
      pack: 'Strip of 20 capsules',
      mrp: 4200,
      price: 3900,
      img: 'assets/images/products/capsules.jpg',
      desc: 'Multivitamin capsule for everyday energy and immunity.',
      uses: ['Vitamin deficiency', 'Fatigue'],
      effects: ['Mild nausea', 'Yellow urine (harmless)'],
    ),
    _med(
      id: 'shelcal-500',
      name: 'Shelcal 500',
      generic: 'Calcium + Vitamin D3',
      salt: 'Calcium Carbonate 500mg + Cholecalciferol 250IU',
      maker: 'Torrent',
      cat: 'vitamins',
      pack: 'Strip of 15 tablets',
      mrp: 12800,
      price: 11500,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'Calcium supplement with vitamin D for bone and joint health.',
      uses: ['Calcium deficiency', 'Bone weakness'],
      effects: ['Constipation', 'Bloating'],
    ),
    _med(
      id: 'limcee-500',
      name: 'Limcee 500',
      generic: 'Vitamin C',
      salt: 'Ascorbic Acid 500mg',
      maker: 'Abbott',
      cat: 'vitamins',
      pack: 'Strip of 15 tablets',
      mrp: 3100,
      price: 2800,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'Chewable vitamin C tablet for immunity and gum health.',
      uses: ['Low immunity', 'Bleeding gums'],
      effects: ['Acidity', 'Stomach upset'],
    ),
    _med(
      id: 'neurobion-forte',
      name: 'Neurobion Forte',
      generic: 'B-Complex',
      salt: 'Vitamin B-Complex with B12',
      maker: 'Merck',
      cat: 'vitamins',
      pack: 'Strip of 30 tablets',
      mrp: 4500,
      price: 4100,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'B-vitamin supplement that supports nerve and muscle function.',
      uses: ['Nerve weakness', 'Vitamin B deficiency'],
      effects: ['Mild tingling', 'Urine discolouration'],
    ),

    // ---- Skin Care ----
    _med(
      id: 'cetaphil-cleanser',
      name: 'Cetaphil Gentle Cleanser',
      generic: 'Gentle cleanser',
      salt: 'Mild surfactant cleansing base',
      maker: 'Galderma',
      cat: 'skin_care',
      pack: 'Bottle of 125 ml',
      mrp: 9900,
      price: 8900,
      img: 'assets/images/products/cream_tube.jpg',
      desc: 'Soap-free cleanser for sensitive, dry or acne-prone skin.',
      uses: ['Daily face wash', 'Sensitive skin'],
      effects: ['Rare irritation', 'None common'],
    ),
    _med(
      id: 'candid-dusting-powder',
      name: 'Candid Dusting Powder',
      generic: 'Clotrimazole',
      salt: 'Clotrimazole 1% w/w',
      maker: 'Glenmark',
      cat: 'skin_care',
      pack: 'Pack of 100 g',
      mrp: 6800,
      price: 6200,
      inStock: false,
      img: 'assets/images/products/tablet_bottle.jpg',
      desc: 'Antifungal powder that keeps skin dry and prevents rashes.',
      uses: ['Fungal infection', 'Heat rash'],
      effects: ['Dryness', 'Itching (rare)'],
    ),
    _med(
      id: 'betnovate-n',
      name: 'Betnovate-N Cream',
      generic: 'Betamethasone topical',
      salt: 'Betamethasone 0.1% + Neomycin 0.5%',
      maker: 'GSK',
      cat: 'skin_care',
      pack: 'Tube of 20 g',
      mrp: 8500,
      price: 7800,
      rx: true,
      img: 'assets/images/products/cream_tube.jpg',
      desc: 'Steroid-antibiotic cream for short-term use in inflamed skin conditions.',
      uses: ['Eczema', 'Allergic dermatitis'],
      effects: ['Skin thinning', 'Burning'],
    ),
    _med(
      id: 'lacto-calamine',
      name: 'Lacto Calamine Oil Balance',
      generic: 'Kaolin lotion',
      salt: 'Kaolin-based calamine lotion',
      maker: 'Pfizer',
      cat: 'skin_care',
      pack: 'Bottle of 120 ml',
      mrp: 9500,
      price: 8600,
      img: 'assets/images/products/cream_tube.jpg',
      desc: 'Oil-control lotion that soothes and refreshes oily skin.',
      uses: ['Oil control', 'Prickly heat'],
      effects: ['Dryness', 'None common'],
    ),

    // ---- Digestive Health ----
    _med(
      id: 'digene-gel',
      name: 'Digene',
      generic: 'Antacid + Simethicone',
      salt: 'Simethicone 50mg + Antacid gel',
      maker: 'Abbott',
      cat: 'digestive_health',
      pack: 'Bottle of 200 ml',
      mrp: 16500,
      price: 15000,
      img: 'assets/images/products/syrup_bottle.jpg',
      desc: 'Mint-flavoured gel that relieves acidity, gas and bloating.',
      uses: ['Acidity', 'Gas and bloating'],
      effects: ['Constipation', 'Loose motions'],
    ),
    _med(
      id: 'pan-40',
      name: 'Pan 40',
      generic: 'Pantoprazole',
      salt: 'Pantoprazole 40mg',
      maker: 'Alkem',
      cat: 'digestive_health',
      pack: 'Strip of 15 tablets',
      mrp: 13200,
      price: 12000,
      rx: true,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'Proton-pump inhibitor that reduces stomach acid production.',
      uses: ['Acid reflux', 'Gastric ulcers'],
      effects: ['Headache', 'Diarrhoea'],
    ),
    _med(
      id: 'omez-20',
      name: 'Omez 20',
      generic: 'Omeprazole',
      salt: 'Omeprazole 20mg',
      maker: 'Dr Reddy\u2019s',
      cat: 'digestive_health',
      pack: 'Strip of 20 capsules',
      mrp: 9600,
      price: 8700,
      rx: true,
      img: 'assets/images/products/capsules.jpg',
      desc: 'Capsule that controls acid reflux and stomach ulcers.',
      uses: ['GERD', 'Heartburn'],
      effects: ['Nausea', 'Gas'],
    ),
    _med(
      id: 'eno-fruit-salt',
      name: 'Eno Fruit Salt',
      generic: 'Antacid effervescent',
      salt: 'Sodium Bicarbonate + Citric Acid',
      maker: 'GSK',
      cat: 'digestive_health',
      pack: 'Pack of 100 g',
      mrp: 13500,
      price: 12500,
      img: 'assets/images/products/tablet_bottle.jpg',
      desc: 'Effervescent powder that gives quick relief from acidity.',
      uses: ['Instant acidity relief', 'Bloating'],
      effects: ['Excess gas', 'Tooth erosion (frequent use)'],
    ),

    // ---- Heart Care ----
    _med(
      id: 'ecosprin-75',
      name: 'Ecosprin 75',
      generic: 'Aspirin',
      salt: 'Aspirin 75mg',
      maker: 'USV',
      cat: 'heart_care',
      pack: 'Strip of 14 tablets',
      mrp: 1250,
      price: 1150,
      rx: true,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'Low-dose aspirin that prevents blood clots and heart attacks.',
      uses: ['Heart attack prevention', 'Stroke prevention'],
      effects: ['Stomach irritation', 'Easy bruising'],
    ),
    _med(
      id: 'telma-40',
      name: 'Telma 40',
      generic: 'Telmisartan',
      salt: 'Telmisartan 40mg',
      maker: 'Glenmark',
      cat: 'heart_care',
      pack: 'Strip of 15 tablets',
      mrp: 16500,
      price: 15200,
      rx: true,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'Angiotensin blocker that controls high blood pressure.',
      uses: ['High blood pressure', 'Heart protection'],
      effects: ['Dizziness', 'Back pain'],
    ),
    _med(
      id: 'rosuvas-10',
      name: 'Rosuvas 10',
      generic: 'Rosuvastatin',
      salt: 'Rosuvastatin 10mg',
      maker: 'Sun Pharma',
      cat: 'heart_care',
      pack: 'Strip of 10 tablets',
      mrp: 18500,
      price: 17000,
      rx: true,
      inStock: false,
      img: 'assets/images/products/tablet_strip.jpg',
      desc: 'Statin that lowers bad cholesterol and triglycerides.',
      uses: ['High cholesterol', 'Cardiovascular risk'],
      effects: ['Muscle pain', 'Headache'],
    ),

    // ---- Baby Care ----
    _med(
      id: 'johnsons-baby-lotion',
      name: 'Johnson\u2019s Baby Lotion',
      generic: 'Baby moisturiser',
      salt: 'Light mineral oil + Glycerin',
      maker: 'Johnson & Johnson',
      cat: 'baby_care',
      pack: 'Bottle of 100 ml',
      mrp: 28500,
      price: 26000,
      img: 'assets/images/products/cream_tube.jpg',
      desc: 'Hypoallergenic lotion that keeps a baby\u2019s skin soft and moisturised.',
      uses: ['Daily moisturising', 'Dry baby skin'],
      effects: ['Rare rash', 'None common'],
    ),
    _med(
      id: 'himalaya-baby-powder',
      name: 'Himalaya Baby Powder',
      generic: 'Baby powder',
      salt: 'Yashimadhu + Olive oil',
      maker: 'Himalaya',
      cat: 'baby_care',
      pack: 'Pack of 100 g',
      mrp: 14500,
      price: 13200,
      inStock: false,
      img: 'assets/images/products/tablet_bottle.jpg',
      desc: 'Mild, chamomile-based powder that prevents nappy rash.',
      uses: ['Nappy rash', 'Skin chafing'],
      effects: ['Dryness', 'None common'],
    ),
    _med(
      id: 'johnsons-baby-wash',
      name: 'Johnson\u2019s Baby Wash',
      generic: 'Baby cleanser',
      salt: 'Tear-free cleansing base',
      maker: 'Johnson & Johnson',
      cat: 'baby_care',
      pack: 'Bottle of 200 ml',
      mrp: 35500,
      price: 32500,
      img: 'assets/images/products/syrup_bottle.jpg',
      desc: 'Tear-free head-to-toe wash for delicate baby skin.',
      uses: ['Baby bath', 'Sensitive skin'],
      effects: ['None common', 'Rare irritation'],
    ),
    _med(
      id: 'colicaid-drops',
      name: 'Colicaid Drops',
      generic: 'Simethicone drops',
      salt: 'Simethicone 40mg/ml',
      maker: 'Sun Pharma',
      cat: 'baby_care',
      pack: 'Bottle of 15 ml',
      mrp: 13500,
      price: 12300,
      img: 'assets/images/products/syrup_bottle.jpg',
      desc: 'Gentle drops that relieve colic and gas in infants.',
      uses: ['Infant colic', 'Gas relief'],
      effects: ['Spit-up', 'None common'],
    ),
  ];

  /// All demo categories.
  Future<List<Category>> fetchCategories() =>
      _withDelay(() => List.unmodifiable(_categories));

  /// All demo products, optionally narrowed to one category.
  Future<List<Product>> fetchProducts({String? categoryId}) =>
      _withDelay(() {
        final all = _products
            .where(
              (p) => categoryId == null ||
                  p.categoryId == categoryId ||
                  categoryId.isEmpty,
            )
            .toList(growable: false);
        return List.unmodifiable(all);
      });

  /// One product by id, or `null` when unknown.
  Future<Product?> fetchProduct(String id) => _withDelay(
        () => _products.where((p) => p.id == id).firstOrNull,
      );

  /// Case-insensitive substring match over brand, generic name and salt.
  Future<List<Product>> search(String query) => _withDelay(() {
        final q = query.trim().toLowerCase();
        if (q.isEmpty) return const <Product>[];
        final matches = _products
            .where(
              (p) =>
                  p.name.toLowerCase().contains(q) ||
                  p.genericName.toLowerCase().contains(q) ||
                  p.salt.toLowerCase().contains(q),
            )
            .toList(growable: false);
        return List.unmodifiable(matches);
      });

  static Product _med({
    required String id,
    required String name,
    required String generic,
    required String salt,
    required String maker,
    required String cat,
    required String pack,
    required int mrp,
    required int price,
    required String desc,
    required List<String> uses,
    required List<String> effects,
    bool rx = false,
    bool inStock = true,
    String? img,
  }) =>
      Product(
        id: id,
        name: name,
        genericName: generic,
        salt: salt,
        manufacturer: maker,
        categoryId: cat,
        packSize: pack,
        mrp: mrp,
        price: price,
        requiresPrescription: rx,
        inStock: inStock,
        description: desc,
        uses: uses,
        sideEffects: effects,
        storage: _storeBelow30,
        imageAsset: img,
      );
}
