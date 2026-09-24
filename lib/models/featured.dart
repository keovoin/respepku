import 'meal.dart';

/// Hand-crafted featured recipe: Mie Goreng Spesial ("Resep Spesial Hari Ini").
Meal getFeaturedMeal() => const Meal(
      id: 'featured-mie-goreng',
      name: 'Mie Goreng Spesial',
      image: 'https://www.themealdb.com/images/media/meals/wvpsrx1511499548.jpg',
      area: 'Indonesia',
      category: 'Mie & Pasta',
      tags: 'Indonesian,Noodles,Spicy',
      ingredients: [
        Ingredient('Mie telur', '200 gram'),
        Ingredient('Telur', '2 butir'),
        Ingredient('Ayam suwir', '100 gram'),
        Ingredient('Sawi hijau', '100 gram'),
        Ingredient('Bawang bombay, iris', '1 buah'),
        Ingredient('Kecap manis', '3 sdm'),
        Ingredient('Saus tiram', '1 sdm'),
        Ingredient('Minyak goreng', '3 sdm'),
        Ingredient('Garam', 'secukupnya'),
        Ingredient('Merica bubuk', '1/2 sdt'),
      ],
      bumbu: [
        Ingredient('Bawang merah, haluskan', '4 siung'),
        Ingredient('Bawang putih, haluskan', '3 siung'),
        Ingredient('Cabai merah keriting', '3 buah'),
        Ingredient('Cabai rawit (opsional)', '2 buah'),
        Ingredient('Tomat, haluskan', '1 buah'),
      ],
      instructions:
          'Rebus mie telur hingga setengah matang, tiriskan dan beri sedikit minyak agar tidak menggumpal.\n'
          'Haluskan bumbu: bawang merah, bawang putih, cabai, dan tomat. Tumis bumbu hingga harum dan matang.\n'
          'Masukkan ayam suwir, aduk rata hingga berubah warna.\n'
          'Tambahkan bawang bombay dan sawi, tumis sebentar hingga layu.\n'
          'Masukkan mie, kecap manis, saus tiram, garam, dan merica. Aduk rata dengan api besar.\n'
          'Masukkan telur orak-arik, aduk hingga matang merata. Koreksi rasa.\n'
          'Sajikan hangat, taburi bawang goreng dan irisan mentri.',
      rating: 4.8,
      ratingsCount: 320,
      minutes: 20,
      difficulty: 'Mudah',
      servings: 2,
      kcal: 520,
      carb: 45,
      protein: 18,
      fat: 22,
      isMock: true,
    );
