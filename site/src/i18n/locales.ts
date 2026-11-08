/**
 * The site's languages. English lives at the root (`/games/`); every other
 * language has a path prefix (`/vi/games/`). Slugs stay English in every
 * language so one page has one slug everywhere.
 *
 * A language is published only once its UI dictionary exists in
 * `src/i18n/ui/<code>.json`, so half-finished languages never ship as
 * duplicate English pages.
 */
export interface LocaleInfo {
  /** Our code, also the dictionary file name. */
  code: string;
  /** URL prefix without slashes; '' for English. */
  prefix: string;
  /** Value for hreflang and Intl formatting. */
  bcp47: string;
  /** Value for <html lang>; English pages keep their US English tag. */
  htmlLang: string;
  /** Open Graph locale. */
  og: string;
  /** Native name, for the language menu. */
  name: string;
  /** English name, for records and alt text. */
  englishName: string;
  dir: 'ltr' | 'rtl';
}

export const DEFAULT_LOCALE = 'en';

export const LOCALES: readonly LocaleInfo[] = [
  { code: 'en', prefix: '', bcp47: 'en', htmlLang: 'en-US', og: 'en_US', name: 'English', englishName: 'English', dir: 'ltr' },
  { code: 'es', prefix: 'es', bcp47: 'es', htmlLang: 'es', og: 'es_ES', name: 'Español', englishName: 'Spanish', dir: 'ltr' },
  { code: 'pt-BR', prefix: 'pt-br', bcp47: 'pt-BR', htmlLang: 'pt-BR', og: 'pt_BR', name: 'Português (Brasil)', englishName: 'Portuguese (Brazil)', dir: 'ltr' },
  { code: 'fr', prefix: 'fr', bcp47: 'fr', htmlLang: 'fr', og: 'fr_FR', name: 'Français', englishName: 'French', dir: 'ltr' },
  { code: 'de', prefix: 'de', bcp47: 'de', htmlLang: 'de', og: 'de_DE', name: 'Deutsch', englishName: 'German', dir: 'ltr' },
  { code: 'it', prefix: 'it', bcp47: 'it', htmlLang: 'it', og: 'it_IT', name: 'Italiano', englishName: 'Italian', dir: 'ltr' },
  { code: 'nl', prefix: 'nl', bcp47: 'nl', htmlLang: 'nl', og: 'nl_NL', name: 'Nederlands', englishName: 'Dutch', dir: 'ltr' },
  { code: 'pl', prefix: 'pl', bcp47: 'pl', htmlLang: 'pl', og: 'pl_PL', name: 'Polski', englishName: 'Polish', dir: 'ltr' },
  { code: 'ru', prefix: 'ru', bcp47: 'ru', htmlLang: 'ru', og: 'ru_RU', name: 'Русский', englishName: 'Russian', dir: 'ltr' },
  { code: 'uk', prefix: 'uk', bcp47: 'uk', htmlLang: 'uk', og: 'uk_UA', name: 'Українська', englishName: 'Ukrainian', dir: 'ltr' },
  { code: 'tr', prefix: 'tr', bcp47: 'tr', htmlLang: 'tr', og: 'tr_TR', name: 'Türkçe', englishName: 'Turkish', dir: 'ltr' },
  { code: 'ar', prefix: 'ar', bcp47: 'ar', htmlLang: 'ar', og: 'ar_AR', name: 'العربية', englishName: 'Arabic', dir: 'rtl' },
  { code: 'hi', prefix: 'hi', bcp47: 'hi', htmlLang: 'hi', og: 'hi_IN', name: 'हिन्दी', englishName: 'Hindi', dir: 'ltr' },
  { code: 'ja', prefix: 'ja', bcp47: 'ja', htmlLang: 'ja', og: 'ja_JP', name: '日本語', englishName: 'Japanese', dir: 'ltr' },
  { code: 'ko', prefix: 'ko', bcp47: 'ko', htmlLang: 'ko', og: 'ko_KR', name: '한국어', englishName: 'Korean', dir: 'ltr' },
  { code: 'zh-Hans', prefix: 'zh-hans', bcp47: 'zh-Hans', htmlLang: 'zh-Hans', og: 'zh_CN', name: '简体中文', englishName: 'Chinese (Simplified)', dir: 'ltr' },
  { code: 'zh-Hant', prefix: 'zh-hant', bcp47: 'zh-Hant', htmlLang: 'zh-Hant', og: 'zh_TW', name: '繁體中文', englishName: 'Chinese (Traditional)', dir: 'ltr' },
  { code: 'vi', prefix: 'vi', bcp47: 'vi', htmlLang: 'vi', og: 'vi_VN', name: 'Tiếng Việt', englishName: 'Vietnamese', dir: 'ltr' },
  { code: 'id', prefix: 'id', bcp47: 'id', htmlLang: 'id', og: 'id_ID', name: 'Bahasa Indonesia', englishName: 'Indonesian', dir: 'ltr' },
  { code: 'th', prefix: 'th', bcp47: 'th', htmlLang: 'th', og: 'th_TH', name: 'ไทย', englishName: 'Thai', dir: 'ltr' },
  { code: 'bn', prefix: 'bn', bcp47: 'bn', htmlLang: 'bn', og: 'bn_BD', name: 'বাংলা', englishName: 'Bengali', dir: 'ltr' },
  { code: 'fa', prefix: 'fa', bcp47: 'fa', htmlLang: 'fa', og: 'fa_IR', name: 'فارسی', englishName: 'Persian', dir: 'rtl' },
  { code: 'ha', prefix: 'ha', bcp47: 'ha', htmlLang: 'ha', og: 'ha_NG', name: 'Hausa', englishName: 'Hausa', dir: 'ltr' },
  { code: 'ur', prefix: 'ur', bcp47: 'ur', htmlLang: 'ur', og: 'ur_PK', name: 'اردو', englishName: 'Urdu', dir: 'rtl' },
  { code: 'mr', prefix: 'mr', bcp47: 'mr', htmlLang: 'mr', og: 'mr_IN', name: 'मराठी', englishName: 'Marathi', dir: 'ltr' },
  { code: 'te', prefix: 'te', bcp47: 'te', htmlLang: 'te', og: 'te_IN', name: 'తెలుగు', englishName: 'Telugu', dir: 'ltr' },
  { code: 'ta', prefix: 'ta', bcp47: 'ta', htmlLang: 'ta', og: 'ta_IN', name: 'தமிழ்', englishName: 'Tamil', dir: 'ltr' },
  { code: 'gu', prefix: 'gu', bcp47: 'gu', htmlLang: 'gu', og: 'gu_IN', name: 'ગુજરાતી', englishName: 'Gujarati', dir: 'ltr' },
  { code: 'pa', prefix: 'pa', bcp47: 'pa', htmlLang: 'pa', og: 'pa_IN', name: 'ਪੰਜਾਬੀ', englishName: 'Punjabi (Gurmukhi)', dir: 'ltr' },
  { code: 'fil', prefix: 'fil', bcp47: 'fil', htmlLang: 'fil', og: 'fil_PH', name: 'Filipino', englishName: 'Filipino', dir: 'ltr' },
  { code: 'ro', prefix: 'ro', bcp47: 'ro', htmlLang: 'ro', og: 'ro_RO', name: 'Română', englishName: 'Romanian', dir: 'ltr' },
  { code: 'ms', prefix: 'ms', bcp47: 'ms', htmlLang: 'ms', og: 'ms_MY', name: 'Bahasa Melayu', englishName: 'Malay', dir: 'ltr' },
  { code: 'sw', prefix: 'sw', bcp47: 'sw', htmlLang: 'sw', og: 'sw_KE', name: 'Kiswahili', englishName: 'Swahili', dir: 'ltr' },
  { code: 'kn', prefix: 'kn', bcp47: 'kn', htmlLang: 'kn', og: 'kn_IN', name: 'ಕನ್ನಡ', englishName: 'Kannada', dir: 'ltr' },
  { code: 'ml', prefix: 'ml', bcp47: 'ml', htmlLang: 'ml', og: 'ml_IN', name: 'മലയാളം', englishName: 'Malayalam', dir: 'ltr' },
  { code: 'ne', prefix: 'ne', bcp47: 'ne', htmlLang: 'ne', og: 'ne_NP', name: 'नेपाली', englishName: 'Nepali', dir: 'ltr' },
  { code: 'az', prefix: 'az', bcp47: 'az', htmlLang: 'az', og: 'az_AZ', name: 'Azərbaycan dili', englishName: 'Azerbaijani', dir: 'ltr' },
  { code: 'am', prefix: 'am', bcp47: 'am', htmlLang: 'am', og: 'am_ET', name: 'አማርኛ', englishName: 'Amharic', dir: 'ltr' },
  { code: 'my', prefix: 'my', bcp47: 'my', htmlLang: 'my', og: 'my_MM', name: 'မြန်မာ', englishName: 'Burmese', dir: 'ltr' },
  { code: 'uz', prefix: 'uz', bcp47: 'uz', htmlLang: 'uz', og: 'uz_UZ', name: 'Oʻzbekcha', englishName: 'Uzbek', dir: 'ltr' },
  { code: 'or', prefix: 'or', bcp47: 'or', htmlLang: 'or', og: 'or_IN', name: 'ଓଡ଼ିଆ', englishName: 'Odia', dir: 'ltr' },
  { code: 'as', prefix: 'as', bcp47: 'as', htmlLang: 'as', og: 'as_IN', name: 'অসমীয়া', englishName: 'Assamese', dir: 'ltr' },
  { code: 'ps', prefix: 'ps', bcp47: 'ps', htmlLang: 'ps', og: 'ps_AF', name: 'پښتو', englishName: 'Pashto', dir: 'rtl' },
  { code: 'yo', prefix: 'yo', bcp47: 'yo', htmlLang: 'yo', og: 'yo_NG', name: 'Yorùbá', englishName: 'Yoruba', dir: 'ltr' },
  { code: 'ig', prefix: 'ig', bcp47: 'ig', htmlLang: 'ig', og: 'ig_NG', name: 'Igbo', englishName: 'Igbo', dir: 'ltr' },
  { code: 'zu', prefix: 'zu', bcp47: 'zu', htmlLang: 'zu', og: 'zu_ZA', name: 'isiZulu', englishName: 'Zulu', dir: 'ltr' },
  { code: 'so', prefix: 'so', bcp47: 'so', htmlLang: 'so', og: 'so_SO', name: 'Soomaali', englishName: 'Somali', dir: 'ltr' },
  { code: 'om', prefix: 'om', bcp47: 'om', htmlLang: 'om', og: 'om_ET', name: 'Afaan Oromoo', englishName: 'Oromo', dir: 'ltr' },
  { code: 'jv', prefix: 'jv', bcp47: 'jv', htmlLang: 'jv', og: 'jv_ID', name: 'Basa Jawa', englishName: 'Javanese', dir: 'ltr' },
  { code: 'su', prefix: 'su', bcp47: 'su', htmlLang: 'su', og: 'su_ID', name: 'Basa Sunda', englishName: 'Sundanese', dir: 'ltr' },
  { code: 'sd', prefix: 'sd', bcp47: 'sd', htmlLang: 'sd', og: 'sd_PK', name: 'سنڌي', englishName: 'Sindhi', dir: 'rtl' },
  { code: 'ca', prefix: 'ca', bcp47: 'ca', htmlLang: 'ca', og: 'ca_ES', name: 'Català', englishName: 'Catalan', dir: 'ltr' },
  { code: 'cs', prefix: 'cs', bcp47: 'cs', htmlLang: 'cs', og: 'cs_CZ', name: 'Čeština', englishName: 'Czech', dir: 'ltr' },
  { code: 'da', prefix: 'da', bcp47: 'da', htmlLang: 'da', og: 'da_DK', name: 'Dansk', englishName: 'Danish', dir: 'ltr' },
  { code: 'el', prefix: 'el', bcp47: 'el', htmlLang: 'el', og: 'el_GR', name: 'Ελληνικά', englishName: 'Greek', dir: 'ltr' },
  { code: 'fi', prefix: 'fi', bcp47: 'fi', htmlLang: 'fi', og: 'fi_FI', name: 'Suomi', englishName: 'Finnish', dir: 'ltr' },
  { code: 'he', prefix: 'he', bcp47: 'he', htmlLang: 'he', og: 'he_IL', name: 'עברית', englishName: 'Hebrew', dir: 'rtl' },
  { code: 'hr', prefix: 'hr', bcp47: 'hr', htmlLang: 'hr', og: 'hr_HR', name: 'Hrvatski', englishName: 'Croatian', dir: 'ltr' },
  { code: 'hu', prefix: 'hu', bcp47: 'hu', htmlLang: 'hu', og: 'hu_HU', name: 'Magyar', englishName: 'Hungarian', dir: 'ltr' },
  { code: 'nb', prefix: 'nb', bcp47: 'nb', htmlLang: 'nb', og: 'nb_NO', name: 'Norsk bokmål', englishName: 'Norwegian Bokmål', dir: 'ltr' },
  { code: 'pt-PT', prefix: 'pt-pt', bcp47: 'pt-PT', htmlLang: 'pt-PT', og: 'pt_PT', name: 'Português (Portugal)', englishName: 'Portuguese (Portugal)', dir: 'ltr' },
  { code: 'sk', prefix: 'sk', bcp47: 'sk', htmlLang: 'sk', og: 'sk_SK', name: 'Slovenčina', englishName: 'Slovak', dir: 'ltr' },
  { code: 'sl', prefix: 'sl', bcp47: 'sl', htmlLang: 'sl', og: 'sl_SI', name: 'Slovenščina', englishName: 'Slovenian', dir: 'ltr' },
  { code: 'sv', prefix: 'sv', bcp47: 'sv', htmlLang: 'sv', og: 'sv_SE', name: 'Svenska', englishName: 'Swedish', dir: 'ltr' },
  { code: 'mn', prefix: 'mn', bcp47: 'mn', htmlLang: 'mn', og: 'mn_MN', name: 'Монгол хэл', englishName: 'Mongolian', dir: 'ltr' },
  { code: 'aa', prefix: 'aa', bcp47: 'aa', htmlLang: 'aa', og: 'aa_ET', name: 'Afaraf', englishName: 'Afar', dir: 'ltr' },
  { code: 'ab', prefix: 'ab', bcp47: 'ab', htmlLang: 'ab', og: 'ab_GE', name: 'Аҧсуа бызшәа', englishName: 'Abkhaz', dir: 'ltr' },
  { code: 'ae', prefix: 'ae', bcp47: 'ae', htmlLang: 'ae', og: 'ae_IR', name: 'Avesta', englishName: 'Avestan', dir: 'ltr' },
  { code: 'af', prefix: 'af', bcp47: 'af', htmlLang: 'af', og: 'af_ZA', name: 'Afrikaans', englishName: 'Afrikaans', dir: 'ltr' },
  { code: 'ak', prefix: 'ak', bcp47: 'ak', htmlLang: 'ak', og: 'ak_GH', name: 'Akan', englishName: 'Akan', dir: 'ltr' },
  { code: 'an', prefix: 'an', bcp47: 'an', htmlLang: 'an', og: 'an_ES', name: 'Aragonés', englishName: 'Aragonese', dir: 'ltr' },
  { code: 'av', prefix: 'av', bcp47: 'av', htmlLang: 'av', og: 'av_RU', name: 'Авар мацӀ', englishName: 'Avaric', dir: 'ltr' },
  { code: 'ay', prefix: 'ay', bcp47: 'ay', htmlLang: 'ay', og: 'ay_BO', name: 'Aymar aru', englishName: 'Aymara', dir: 'ltr' },
  { code: 'azb', prefix: 'azb', bcp47: 'azb', htmlLang: 'azb', og: 'azb_IR', name: 'تورکجه', englishName: 'South Azerbaijani', dir: 'rtl' },
  { code: 'ba', prefix: 'ba', bcp47: 'ba', htmlLang: 'ba', og: 'ba_RU', name: 'Башҡорт теле', englishName: 'Bashkir', dir: 'ltr' },
  { code: 'be', prefix: 'be', bcp47: 'be', htmlLang: 'be', og: 'be_BY', name: 'Беларуская', englishName: 'Belarusian', dir: 'ltr' },
  { code: 'bg', prefix: 'bg', bcp47: 'bg', htmlLang: 'bg', og: 'bg_BG', name: 'Български', englishName: 'Bulgarian', dir: 'ltr' },
  { code: 'bh', prefix: 'bh', bcp47: 'bh', htmlLang: 'bh', og: 'bh_IN', name: 'भोजपुरी', englishName: 'Bihari', dir: 'ltr' },
  { code: 'bi', prefix: 'bi', bcp47: 'bi', htmlLang: 'bi', og: 'bi_VU', name: 'Bislama', englishName: 'Bislama', dir: 'ltr' },
  { code: 'bm', prefix: 'bm', bcp47: 'bm', htmlLang: 'bm', og: 'bm_ML', name: 'Bamanankan', englishName: 'Bambara', dir: 'ltr' },
  { code: 'bo', prefix: 'bo', bcp47: 'bo', htmlLang: 'bo', og: 'bo_CN', name: 'བོད་ཡིག', englishName: 'Tibetan Standard', dir: 'ltr' },
  { code: 'br', prefix: 'br', bcp47: 'br', htmlLang: 'br', og: 'br_FR', name: 'Brezhoneg', englishName: 'Breton', dir: 'ltr' },
  { code: 'bs', prefix: 'bs', bcp47: 'bs', htmlLang: 'bs', og: 'bs_BA', name: 'Bosanski', englishName: 'Bosnian', dir: 'ltr' },
  { code: 'ce', prefix: 'ce', bcp47: 'ce', htmlLang: 'ce', og: 'ce_RU', name: 'Нохчийн мотт', englishName: 'Chechen', dir: 'ltr' },
  { code: 'ch', prefix: 'ch', bcp47: 'ch', htmlLang: 'ch', og: 'ch_GU', name: 'Chamoru', englishName: 'Chamorro', dir: 'ltr' },
  { code: 'co', prefix: 'co', bcp47: 'co', htmlLang: 'co', og: 'co_FR', name: 'Corsu', englishName: 'Corsican', dir: 'ltr' },
  { code: 'cr', prefix: 'cr', bcp47: 'cr', htmlLang: 'cr', og: 'cr_CA', name: 'ᓀᐦᐃᔭᐍᐏᐣ', englishName: 'Cree', dir: 'ltr' },
  { code: 'cu', prefix: 'cu', bcp47: 'cu', htmlLang: 'cu', og: 'cu_BG', name: 'Ѩзыкъ словѣньскъ', englishName: 'Old Church Slavonic', dir: 'ltr' },
  { code: 'cv', prefix: 'cv', bcp47: 'cv', htmlLang: 'cv', og: 'cv_RU', name: 'Чӑваш чӗлхи', englishName: 'Chuvash', dir: 'ltr' },
  { code: 'cy', prefix: 'cy', bcp47: 'cy', htmlLang: 'cy', og: 'cy_GB', name: 'Cymraeg', englishName: 'Welsh', dir: 'ltr' },
  { code: 'dv', prefix: 'dv', bcp47: 'dv', htmlLang: 'dv', og: 'dv_MV', name: 'ދިވެހި', englishName: 'Divehi', dir: 'rtl' },
  { code: 'dz', prefix: 'dz', bcp47: 'dz', htmlLang: 'dz', og: 'dz_BT', name: 'རྫོང་ཁ', englishName: 'Dzongkha', dir: 'ltr' },
  { code: 'ee', prefix: 'ee', bcp47: 'ee', htmlLang: 'ee', og: 'ee_GH', name: 'Eʋegbe', englishName: 'Ewe', dir: 'ltr' },
  { code: 'eo', prefix: 'eo', bcp47: 'eo', htmlLang: 'eo', og: 'eo_001', name: 'Esperanto', englishName: 'Esperanto', dir: 'ltr' },
  { code: 'et', prefix: 'et', bcp47: 'et', htmlLang: 'et', og: 'et_EE', name: 'Eesti', englishName: 'Estonian', dir: 'ltr' },
  { code: 'eu', prefix: 'eu', bcp47: 'eu', htmlLang: 'eu', og: 'eu_ES', name: 'Euskara', englishName: 'Basque', dir: 'ltr' },
  { code: 'ff', prefix: 'ff', bcp47: 'ff', htmlLang: 'ff', og: 'ff_SN', name: 'Fulfulde', englishName: 'Fula', dir: 'ltr' },
  { code: 'fj', prefix: 'fj', bcp47: 'fj', htmlLang: 'fj', og: 'fj_FJ', name: 'Vosa Vakaviti', englishName: 'Fijian', dir: 'ltr' },
  { code: 'fo', prefix: 'fo', bcp47: 'fo', htmlLang: 'fo', og: 'fo_FO', name: 'Føroyskt', englishName: 'Faroese', dir: 'ltr' },
  { code: 'fy', prefix: 'fy', bcp47: 'fy', htmlLang: 'fy', og: 'fy_NL', name: 'Frysk', englishName: 'Western Frisian', dir: 'ltr' },
  { code: 'ga', prefix: 'ga', bcp47: 'ga', htmlLang: 'ga', og: 'ga_IE', name: 'Gaeilge', englishName: 'Irish', dir: 'ltr' },
  { code: 'gd', prefix: 'gd', bcp47: 'gd', htmlLang: 'gd', og: 'gd_GB', name: 'Gàidhlig', englishName: 'Scottish Gaelic', dir: 'ltr' },
  { code: 'gl', prefix: 'gl', bcp47: 'gl', htmlLang: 'gl', og: 'gl_ES', name: 'Galego', englishName: 'Galician', dir: 'ltr' },
  { code: 'gn', prefix: 'gn', bcp47: 'gn', htmlLang: 'gn', og: 'gn_PY', name: 'Avañe\'ẽ', englishName: 'Guaraní', dir: 'ltr' },
  { code: 'gv', prefix: 'gv', bcp47: 'gv', htmlLang: 'gv', og: 'gv_IM', name: 'Gaelg', englishName: 'Manx', dir: 'ltr' },
  { code: 'ho', prefix: 'ho', bcp47: 'ho', htmlLang: 'ho', og: 'ho_PG', name: 'Hiri Motu', englishName: 'Hiri Motu', dir: 'ltr' },
  { code: 'ht', prefix: 'ht', bcp47: 'ht', htmlLang: 'ht', og: 'ht_HT', name: 'Kreyòl ayisyen', englishName: 'Haitian', dir: 'ltr' },
  { code: 'hy', prefix: 'hy', bcp47: 'hy', htmlLang: 'hy', og: 'hy_AM', name: 'Հայերեն', englishName: 'Armenian', dir: 'ltr' },
  { code: 'hz', prefix: 'hz', bcp47: 'hz', htmlLang: 'hz', og: 'hz_NA', name: 'Otjiherero', englishName: 'Herero', dir: 'ltr' },
  { code: 'ia', prefix: 'ia', bcp47: 'ia', htmlLang: 'ia', og: 'ia_001', name: 'Interlingua', englishName: 'Interlingua', dir: 'ltr' },
  { code: 'ie', prefix: 'ie', bcp47: 'ie', htmlLang: 'ie', og: 'ie_001', name: 'Interlingue', englishName: 'Interlingue', dir: 'ltr' },
  { code: 'ii', prefix: 'ii', bcp47: 'ii', htmlLang: 'ii', og: 'ii_CN', name: 'ꆈꌠ꒿ Nuosuhxop', englishName: 'Nuosu', dir: 'ltr' },
  { code: 'ik', prefix: 'ik', bcp47: 'ik', htmlLang: 'ik', og: 'ik_US', name: 'Iñupiaq', englishName: 'Inupiaq', dir: 'ltr' },
  { code: 'io', prefix: 'io', bcp47: 'io', htmlLang: 'io', og: 'io_001', name: 'Ido', englishName: 'Ido', dir: 'ltr' },
  { code: 'is', prefix: 'is', bcp47: 'is', htmlLang: 'is', og: 'is_IS', name: 'Íslenska', englishName: 'Icelandic', dir: 'ltr' },
  { code: 'iu', prefix: 'iu', bcp47: 'iu', htmlLang: 'iu', og: 'iu_CA', name: 'ᐃᓄᒃᑎᑐᑦ', englishName: 'Inuktitut', dir: 'ltr' },
  { code: 'ka', prefix: 'ka', bcp47: 'ka', htmlLang: 'ka', og: 'ka_GE', name: 'Ქართული', englishName: 'Georgian', dir: 'ltr' },
  { code: 'kg', prefix: 'kg', bcp47: 'kg', htmlLang: 'kg', og: 'kg_CD', name: 'KiKongo', englishName: 'Kongo', dir: 'ltr' },
  { code: 'ki', prefix: 'ki', bcp47: 'ki', htmlLang: 'ki', og: 'ki_KE', name: 'Gĩkũyũ', englishName: 'Kikuyu', dir: 'ltr' },
  { code: 'kj', prefix: 'kj', bcp47: 'kj', htmlLang: 'kj', og: 'kj_AO', name: 'Kuanyama', englishName: 'Kwanyama', dir: 'ltr' },
  { code: 'kk', prefix: 'kk', bcp47: 'kk', htmlLang: 'kk', og: 'kk_KZ', name: 'Қазақ тілі', englishName: 'Kazakh', dir: 'ltr' },
  { code: 'kl', prefix: 'kl', bcp47: 'kl', htmlLang: 'kl', og: 'kl_GL', name: 'Kalaallisut', englishName: 'Kalaallisut', dir: 'ltr' },
  { code: 'km', prefix: 'km', bcp47: 'km', htmlLang: 'km', og: 'km_KH', name: 'ខ្មែរ', englishName: 'Khmer', dir: 'ltr' },
  { code: 'kr', prefix: 'kr', bcp47: 'kr', htmlLang: 'kr', og: 'kr_NG', name: 'Kanuri', englishName: 'Kanuri', dir: 'ltr' },
  { code: 'ks', prefix: 'ks', bcp47: 'ks', htmlLang: 'ks', og: 'ks_IN', name: 'كشميري', englishName: 'Kashmiri', dir: 'rtl' },
  { code: 'ku', prefix: 'ku', bcp47: 'ku', htmlLang: 'ku', og: 'ku_TR', name: 'Kurdî', englishName: 'Kurdish', dir: 'ltr' },
  { code: 'kv', prefix: 'kv', bcp47: 'kv', htmlLang: 'kv', og: 'kv_RU', name: 'Коми кыв', englishName: 'Komi', dir: 'ltr' },
  { code: 'kw', prefix: 'kw', bcp47: 'kw', htmlLang: 'kw', og: 'kw_GB', name: 'Kernewek', englishName: 'Cornish', dir: 'ltr' },
  { code: 'ky', prefix: 'ky', bcp47: 'ky', htmlLang: 'ky', og: 'ky_KG', name: 'Кыргызча', englishName: 'Kyrgyz', dir: 'ltr' },
  { code: 'la', prefix: 'la', bcp47: 'la', htmlLang: 'la', og: 'la_VA', name: 'Latina', englishName: 'Latin', dir: 'ltr' },
  { code: 'lb', prefix: 'lb', bcp47: 'lb', htmlLang: 'lb', og: 'lb_LU', name: 'Lëtzebuergesch', englishName: 'Luxembourgish', dir: 'ltr' },
  { code: 'lg', prefix: 'lg', bcp47: 'lg', htmlLang: 'lg', og: 'lg_UG', name: 'Luganda', englishName: 'Ganda', dir: 'ltr' },
  { code: 'li', prefix: 'li', bcp47: 'li', htmlLang: 'li', og: 'li_NL', name: 'Limburgs', englishName: 'Limburgish', dir: 'ltr' },
  { code: 'ln', prefix: 'ln', bcp47: 'ln', htmlLang: 'ln', og: 'ln_CD', name: 'Lingála', englishName: 'Lingala', dir: 'ltr' },
  { code: 'lo', prefix: 'lo', bcp47: 'lo', htmlLang: 'lo', og: 'lo_LA', name: 'ພາສາລາວ', englishName: 'Lao', dir: 'ltr' },
  { code: 'lt', prefix: 'lt', bcp47: 'lt', htmlLang: 'lt', og: 'lt_LT', name: 'Lietuvių', englishName: 'Lithuanian', dir: 'ltr' },
  { code: 'lu', prefix: 'lu', bcp47: 'lu', htmlLang: 'lu', og: 'lu_CD', name: 'Tshiluba', englishName: 'Luba-Katanga', dir: 'ltr' },
  { code: 'lv', prefix: 'lv', bcp47: 'lv', htmlLang: 'lv', og: 'lv_LV', name: 'Latviešu', englishName: 'Latvian', dir: 'ltr' },
  { code: 'mg', prefix: 'mg', bcp47: 'mg', htmlLang: 'mg', og: 'mg_MG', name: 'Fiteny malagasy', englishName: 'Malagasy', dir: 'ltr' },
  { code: 'mh', prefix: 'mh', bcp47: 'mh', htmlLang: 'mh', og: 'mh_MH', name: 'Kajin M̧ajeļ', englishName: 'Marshallese', dir: 'ltr' },
  { code: 'mi', prefix: 'mi', bcp47: 'mi', htmlLang: 'mi', og: 'mi_NZ', name: 'Te reo Māori', englishName: 'Māori', dir: 'ltr' },
  { code: 'mk', prefix: 'mk', bcp47: 'mk', htmlLang: 'mk', og: 'mk_MK', name: 'Македонски', englishName: 'Macedonian', dir: 'ltr' },
  { code: 'mt', prefix: 'mt', bcp47: 'mt', htmlLang: 'mt', og: 'mt_MT', name: 'Malti', englishName: 'Maltese', dir: 'ltr' },
  { code: 'na', prefix: 'na', bcp47: 'na', htmlLang: 'na', og: 'na_NR', name: 'Ekakairũ Naoero', englishName: 'Nauru', dir: 'ltr' },
  { code: 'nd', prefix: 'nd', bcp47: 'nd', htmlLang: 'nd', og: 'nd_ZW', name: 'IsiNdebele', englishName: 'North Ndebele', dir: 'ltr' },
  { code: 'ng', prefix: 'ng', bcp47: 'ng', htmlLang: 'ng', og: 'ng_NA', name: 'Owambo', englishName: 'Ndonga', dir: 'ltr' },
  { code: 'nn', prefix: 'nn', bcp47: 'nn', htmlLang: 'nn', og: 'nn_NO', name: 'Norsk nynorsk', englishName: 'Norwegian Nynorsk', dir: 'ltr' },
  { code: 'no', prefix: 'no', bcp47: 'no', htmlLang: 'no', og: 'no_NO', name: 'Norsk', englishName: 'Norwegian', dir: 'ltr' },
  { code: 'nr', prefix: 'nr', bcp47: 'nr', htmlLang: 'nr', og: 'nr_ZA', name: 'IsiNdebele', englishName: 'South Ndebele', dir: 'ltr' },
  { code: 'nv', prefix: 'nv', bcp47: 'nv', htmlLang: 'nv', og: 'nv_US', name: 'Diné bizaad', englishName: 'Navajo', dir: 'ltr' },
  { code: 'ny', prefix: 'ny', bcp47: 'ny', htmlLang: 'ny', og: 'ny_MW', name: 'ChiCheŵa', englishName: 'Chichewa', dir: 'ltr' },
  { code: 'oc', prefix: 'oc', bcp47: 'oc', htmlLang: 'oc', og: 'oc_FR', name: 'Occitan', englishName: 'Occitan', dir: 'ltr' },
  { code: 'oj', prefix: 'oj', bcp47: 'oj', htmlLang: 'oj', og: 'oj_CA', name: 'ᐊᓂᔑᓈᐯᒧᐎᓐ', englishName: 'Ojibwe', dir: 'ltr' },
  { code: 'os', prefix: 'os', bcp47: 'os', htmlLang: 'os', og: 'os_GE', name: 'Ирон æвзаг', englishName: 'Ossetian', dir: 'ltr' },
  { code: 'pi', prefix: 'pi', bcp47: 'pi', htmlLang: 'pi', og: 'pi_IN', name: 'पालि', englishName: 'Pāli', dir: 'ltr' },
  { code: 'pt', prefix: 'pt', bcp47: 'pt', htmlLang: 'pt', og: 'pt_PT', name: 'Português', englishName: 'Portuguese', dir: 'ltr' },
  { code: 'qu', prefix: 'qu', bcp47: 'qu', htmlLang: 'qu', og: 'qu_PE', name: 'Runa Simi', englishName: 'Quechua', dir: 'ltr' },
  { code: 'rm', prefix: 'rm', bcp47: 'rm', htmlLang: 'rm', og: 'rm_CH', name: 'Rumantsch', englishName: 'Romansh', dir: 'ltr' },
  { code: 'rn', prefix: 'rn', bcp47: 'rn', htmlLang: 'rn', og: 'rn_BI', name: 'Ikirundi', englishName: 'Kirundi', dir: 'ltr' },
  { code: 'rw', prefix: 'rw', bcp47: 'rw', htmlLang: 'rw', og: 'rw_RW', name: 'Ikinyarwanda', englishName: 'Kinyarwanda', dir: 'ltr' },
  { code: 'sa', prefix: 'sa', bcp47: 'sa', htmlLang: 'sa', og: 'sa_IN', name: 'संस्कृतम्', englishName: 'Sanskrit (Saṁskṛta)', dir: 'ltr' },
  { code: 'sc', prefix: 'sc', bcp47: 'sc', htmlLang: 'sc', og: 'sc_IT', name: 'Sardu', englishName: 'Sardinian', dir: 'ltr' },
  { code: 'se', prefix: 'se', bcp47: 'se', htmlLang: 'se', og: 'se_NO', name: 'Davvisámegiella', englishName: 'Northern Sami', dir: 'ltr' },
  { code: 'sg', prefix: 'sg', bcp47: 'sg', htmlLang: 'sg', og: 'sg_CF', name: 'Yângâ tî sängö', englishName: 'Sango', dir: 'ltr' },
  { code: 'si', prefix: 'si', bcp47: 'si', htmlLang: 'si', og: 'si_LK', name: 'සිංහල', englishName: 'Sinhala', dir: 'ltr' },
  { code: 'sm', prefix: 'sm', bcp47: 'sm', htmlLang: 'sm', og: 'sm_WS', name: 'Gagana fa\'a Samoa', englishName: 'Samoan', dir: 'ltr' },
  { code: 'sn', prefix: 'sn', bcp47: 'sn', htmlLang: 'sn', og: 'sn_ZW', name: 'ChiShona', englishName: 'Shona', dir: 'ltr' },
  { code: 'sq', prefix: 'sq', bcp47: 'sq', htmlLang: 'sq', og: 'sq_AL', name: 'Shqip', englishName: 'Albanian', dir: 'ltr' },
  { code: 'sr', prefix: 'sr', bcp47: 'sr', htmlLang: 'sr', og: 'sr_RS', name: 'Српски', englishName: 'Serbian', dir: 'ltr' },
  { code: 'ss', prefix: 'ss', bcp47: 'ss', htmlLang: 'ss', og: 'ss_SZ', name: 'SiSwati', englishName: 'Swati', dir: 'ltr' },
  { code: 'st', prefix: 'st', bcp47: 'st', htmlLang: 'st', og: 'st_LS', name: 'Sesotho', englishName: 'Southern Sotho', dir: 'ltr' },
  { code: 'tg', prefix: 'tg', bcp47: 'tg', htmlLang: 'tg', og: 'tg_TJ', name: 'Тоҷикӣ', englishName: 'Tajik', dir: 'ltr' },
  { code: 'ti', prefix: 'ti', bcp47: 'ti', htmlLang: 'ti', og: 'ti_ER', name: 'ትግርኛ', englishName: 'Tigrinya', dir: 'ltr' },
  { code: 'tk', prefix: 'tk', bcp47: 'tk', htmlLang: 'tk', og: 'tk_TM', name: 'Türkmen', englishName: 'Turkmen', dir: 'ltr' },
  { code: 'tl', prefix: 'tl', bcp47: 'tl', htmlLang: 'tl', og: 'tl_PH', name: 'Tagalog', englishName: 'Tagalog', dir: 'ltr' },
  { code: 'tn', prefix: 'tn', bcp47: 'tn', htmlLang: 'tn', og: 'tn_BW', name: 'Setswana', englishName: 'Tswana', dir: 'ltr' },
  { code: 'to', prefix: 'to', bcp47: 'to', htmlLang: 'to', og: 'to_TO', name: 'Faka Tonga', englishName: 'Tonga (Tonga Islands)', dir: 'ltr' },
  { code: 'ts', prefix: 'ts', bcp47: 'ts', htmlLang: 'ts', og: 'ts_ZA', name: 'Xitsonga', englishName: 'Tsonga', dir: 'ltr' },
  { code: 'tt', prefix: 'tt', bcp47: 'tt', htmlLang: 'tt', og: 'tt_RU', name: 'Татар теле', englishName: 'Tatar', dir: 'ltr' },
  { code: 'tw', prefix: 'tw', bcp47: 'tw', htmlLang: 'tw', og: 'tw_GH', name: 'Twi', englishName: 'Twi', dir: 'ltr' },
  { code: 'ty', prefix: 'ty', bcp47: 'ty', htmlLang: 'ty', og: 'ty_PF', name: 'Reo Tahiti', englishName: 'Tahitian', dir: 'ltr' },
  { code: 'ug', prefix: 'ug', bcp47: 'ug', htmlLang: 'ug', og: 'ug_CN', name: 'ئۇيغۇرچە', englishName: 'Uyghur', dir: 'rtl' },
  { code: 've', prefix: 've', bcp47: 've', htmlLang: 've', og: 've_ZA', name: 'Tshivenḓa', englishName: 'Venda', dir: 'ltr' },
  { code: 'vo', prefix: 'vo', bcp47: 'vo', htmlLang: 'vo', og: 'vo_001', name: 'Volapük', englishName: 'Volapük', dir: 'ltr' },
  { code: 'wa', prefix: 'wa', bcp47: 'wa', htmlLang: 'wa', og: 'wa_BE', name: 'Walon', englishName: 'Walloon', dir: 'ltr' },
  { code: 'wo', prefix: 'wo', bcp47: 'wo', htmlLang: 'wo', og: 'wo_SN', name: 'Wollof', englishName: 'Wolof', dir: 'ltr' },
  { code: 'xh', prefix: 'xh', bcp47: 'xh', htmlLang: 'xh', og: 'xh_ZA', name: 'IsiXhosa', englishName: 'Xhosa', dir: 'ltr' },
  { code: 'yi', prefix: 'yi', bcp47: 'yi', htmlLang: 'yi', og: 'yi_001', name: 'ייִдиш', englishName: 'Yiddish', dir: 'rtl' },
  { code: 'za', prefix: 'za', bcp47: 'za', htmlLang: 'za', og: 'za_CN', name: 'Vahcuengh', englishName: 'Zhuang', dir: 'ltr' },
  { code: 'zh', prefix: 'zh', bcp47: 'zh', htmlLang: 'zh', og: 'zh_CN', name: '中文', englishName: 'Chinese', dir: 'ltr' },
];

/**
 * Languages search engines may index, listed in sitemaps, hreflang and
 * llms.txt. Every published language is indexed (maintainer decision,
 * 2026-11-01), including the machine translations: those pages still say they
 * are unreviewed and link to the English original. Remove a code to make that
 * language `noindex` again; TRANSLATING.md tracks which are reviewed.
 *
 * `HELD_FROM_INDEX` is the way to pull a language back out: its pages stay
 * reachable and labelled but become `noindex` and drop out of the sitemaps,
 * hreflang and llms.txt. It is empty: on 2026-11-01 the maintainer chose to
 * index every language, including the weakest machine translations (Hausa,
 * Amharic, Burmese, Pashto, Sindhi, Somali, Oromo), which native speakers
 * should review first.
 */
export const HELD_FROM_INDEX: ReadonlySet<string> = new Set([]);

export const INDEXED_LANGUAGES: ReadonlySet<string> = new Set(
  LOCALES.map((l) => l.code).filter((code) => !HELD_FROM_INDEX.has(code)),
);

export function isIndexable(code: string): boolean {
  return INDEXED_LANGUAGES.has(code);
}

const BY_CODE = new Map(LOCALES.map((l) => [l.code, l]));
const BY_PREFIX = new Map(LOCALES.filter((l) => l.prefix).map((l) => [l.prefix, l]));
const BY_LOWER_CODE = new Map(LOCALES.map((l) => [l.code.toLowerCase(), l.code]));

/**
 * The language of a content folder such as `guides-i18n/pt-BR/`, from the
 * first segment of a collection entry id. Astro's glob loader lowercases
 * entry ids (`pt-BR/activities/music.md` becomes `pt-br/activities/music`),
 * so an exact match would silently drop every guide in pt-BR, pt-PT, zh-Hans
 * and zh-Hant. Returns undefined for a folder that is not a language.
 */
export function localeOfContentDir(dir: string): string | undefined {
  return BY_LOWER_CODE.get(dir.toLowerCase());
}

export function localeInfo(code: string): LocaleInfo {
  return BY_CODE.get(code) ?? (BY_CODE.get(DEFAULT_LOCALE) as LocaleInfo);
}

/** `/games/` in `vi` becomes `/vi/games/`. External and anchor links are untouched. */
export function localePath(code: string, path: string): string {
  if (!path.startsWith('/') || path.startsWith('//')) return path;
  const { prefix } = localeInfo(code);
  return prefix ? `/${prefix}${path}` : path;
}

/** Splits `/vi/games/` into `{ code: 'vi', path: '/games/' }`. */
export function splitLocale(pathname: string): { code: string; path: string } {
  // Two- and three-letter codes (Filipino is `fil`); an unknown prefix such as /app/ is not a language.
  const match = pathname.match(/^\/([a-z]{2,3}(?:-[a-z]{2,4})?)(\/.*)?$/);
  const info = match ? BY_PREFIX.get(match[1] as string) : undefined;
  if (!info || !match) return { code: DEFAULT_LOCALE, path: pathname };
  return { code: info.code, path: match[2] ?? '/' };
}

/** Paths that exist only in English, linked as such from every language. */
export const ENGLISH_ONLY = [
  '/privacy/',
  '/app-privacy/',
  '/privacy-choices/',
  '/terms/',
  '/safety/',
  '/accessibility/',
  '/medical-disclaimer/',
  '/legal/',
  '/support/',
  '/help/',
];

export function isEnglishOnly(path: string): boolean {
  return ENGLISH_ONLY.some((p) => path === p || path.startsWith(p));
}

/**
 * Link to `path` from a page in `code`: language-prefixed, except pages that
 * exist only in English.
 */
export function href(code: string, path: string): string {
  return isEnglishOnly(path) ? path : localePath(code, path);
}

/** Rewrites root-relative links inside trusted dictionary HTML for `code`. */
export function localizeHtml(code: string, html: string): string {
  if (code === DEFAULT_LOCALE) return html;
  return html.replace(/href="(\/[^"]*)"/g, (_, p: string) => `href="${href(code, p)}"`);
}
