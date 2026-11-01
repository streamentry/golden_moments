"""Translated store listings stay within store limits and tone rules (GM-036)."""
import copy
import unittest

from scripts import pack_text, store_locales

GOOD = {
    'language': 'es',
    'app_store_locales': ['es-MX', 'es-ES'],
    'google_play_locales': ['es-419', 'es-US', 'es-ES'],
    'review': 'unreviewed',
    'app_store': {
        'name': 'Demencia: Golden Moments',
        'subtitle': 'Actividades con fotos',
        'keywords': 'alzheimer,memoria,mayores,abuelos',
        'promotional_text': 'Actividades sencillas para disfrutar juntos.',
        'description': 'Actividades sencillas con fotos grandes.',
        'release_notes': 'Ahora en 20 idiomas. Estas traducciones aún no las han revisado hablantes nativos.',
    },
    'google_play': {
        'name': 'Demencia: Golden Moments',
        'short_description': 'Actividades sencillas con fotos para disfrutar juntos.',
        'full_description': 'Actividades sencillas con fotos grandes.',
        'release_notes': 'Ahora en 20 idiomas. Estas traducciones aún no las han revisado hablantes nativos.',
    },
}


def variant(**changes):
    data = copy.deepcopy(GOOD)
    for dotted, value in changes.items():
        section, _, key = dotted.partition('__')
        if key:
            data[section][key] = value
        else:
            data[section] = value
    return data


class StoreLocaleTests(unittest.TestCase):
    def test_repository_listings_pass_the_check(self):
        self.assertEqual(store_locales.check(), [])

    def test_every_app_language_has_store_locales(self):
        # The store languages are exactly the app's languages except English,
        # whose listing lives in metadata/app-store.en-US.json.
        app_languages = {name.replace('_', '-') for name in pack_text.LOCALES}
        self.assertEqual(set(store_locales.LANGUAGES), app_languages - {'en'})
        self.assertNotIn('en', store_locales.LANGUAGES)

    def test_a_good_listing_passes(self):
        self.assertEqual(store_locales.validate('es', GOOD), [])

    def test_store_limits(self):
        long_name = variant(app_store__name='x' * 16 + ' Golden Moments')
        self.assertTrue(store_locales.validate('es', long_name))
        long_short = variant(google_play__short_description='x' * 81)
        self.assertTrue(store_locales.validate('es', long_short))

    def test_keywords_are_counted_in_bytes(self):
        # 34 three-byte characters are 102 bytes although only 34 characters.
        cjk = variant(app_store__keywords='認' * 34)
        self.assertTrue(any('UTF-8 bytes' in e for e in store_locales.validate('es', cjk)))

    def test_keywords_reject_duplicates_spaces_and_visible_words(self):
        for keywords in ('memoria,Memoria', 'memoria, mayores', 'memoria,,mayores',
                         'fotos,memoria'):
            with self.subTest(keywords=keywords):
                data = variant(app_store__keywords=keywords)
                self.assertTrue(store_locales.validate('es', data))

    def test_brand_and_tone(self):
        self.assertTrue(store_locales.validate('es', variant(app_store__name='Juegos de memoria')))
        self.assertTrue(store_locales.validate(
            'es', variant(app_store__promotional_text='¡Juegue ya!')))

    def test_release_notes_are_required_and_match_across_stores(self):
        missing = copy.deepcopy(GOOD)
        del missing['app_store']['release_notes']
        self.assertTrue(store_locales.validate('es', missing))
        long_play = variant(google_play__release_notes='x' * 501)
        self.assertTrue(store_locales.validate('es', long_play))
        differ = variant(google_play__release_notes='Otra nota.')
        self.assertTrue(any('differ' in e for e in store_locales.validate('es', differ)))

    def test_locale_codes_must_match_the_language(self):
        self.assertTrue(store_locales.validate('es', variant(app_store_locales=['es-ES'])))
        self.assertTrue(store_locales.validate('fr', GOOD))
        self.assertTrue(store_locales.validate('en', GOOD))
