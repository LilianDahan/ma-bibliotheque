# Ma Bibliothèque — première version fonctionnelle

Application web responsive, mode jour/nuit, grille de couvertures classées par auteur, panneau latéral, statuts de possession et lecture, collections par ouvrage ou par auteur, recherche ISBN (Google Books puis Open Library), synchronisation cloud par compte privé.

## Mise en ligne (sans installer Node.js)

1. Créez un projet gratuit sur https://supabase.com. Dans **SQL Editor**, exécutez le contenu de `schema.sql` (une seule fois). Le script active la sécurité RLS : chaque utilisateur n'accède qu'à ses propres livres.
2. Dans Supabase, sous **Project Settings > API** (selon l'interface, **Connect** ou **API Keys**), récupérez l'URL du projet et la clé **publishable** ou **anon**. N'utilisez JAMAIS la clé `service_role` ni une clé secrète.
3. Hébergez `index.html` et `manifest.webmanifest` ensemble sur un hébergeur statique HTTPS : par exemple Netlify Drop (https://app.netlify.com/drop), en déposant le dossier entier, ou GitHub Pages. L'application doit être ouverte depuis un site web, pas en `file://`.
4. Ouvrez l'URL publiée. Renseignez l'URL Supabase et la clé publique. Créez un compte avec email et mot de passe. Selon vos réglages Supabase Auth, confirmez l'email. Connectez-vous.
5. Sur votre téléphone, ouvrez la même URL, renseignez la même configuration Supabase et connectez-vous avec **le même compte**. Les livres sont partagés automatiquement via la base cloud. Ajoutez la page à l'écran d'accueil si souhaité.

## Limites de cette V1

- L'ISBN fournit une fiche candidate, à vérifier : les bases externes ne garantissent pas une couverture ou une édition exacte.
- Les données sont conservées dans Supabase, mais il n'y a pas encore de mode hors ligne, d'export, ni de scanner de code-barres par caméra.
- Les auteurs sont identifiés par leur nom normalisé en minuscules pour les collections ; utiliser une orthographe cohérente. L'édition et l'œuvre ne sont pas encore deux entités séparées : chaque ligne représente une fiche de livre/édition.
- L'ajout d'une collection par auteur ne récupère **aucune** bibliographie externe : uniquement les livres déjà enregistrés, y compris ceux ajoutés ensuite.
- Les exclusions d'un ouvrage d'une collection associée à son auteur sont possibles en décochant la collection dans la fiche.
- Pour une synchronisation automatique entre appareils, une connexion internet est nécessaire.

## Confidentialité

Les données sont protégées par des règles RLS Supabase. Pour une utilisation privée, ne désactivez pas ces règles. La configuration publique Supabase est stockée dans le navigateur, pas le mot de passe. La clé anon est prévue pour être publique.
