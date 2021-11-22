module.exports = {
  env: {
    browser: false,
    es2021: true,
    mocha: true,
    node: true,
  },
  plugins: ['@typescript-eslint'],
  extends: [
    'standard',
    'plugin:prettier/recommended',
    'plugin:node/recommended',
  ],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 12,
  },
  "settings": {
    "node": {
        "resolvePaths": ["node_modules/@types"],
        "tryExtensions": [".js", ".json", ".node", ".ts", ".d.ts"]
    },
  },
  rules: {
    'node/no-unsupported-features/es-syntax': [
      'error',
      { ignores: ['modules'] },
    ],
    'prettier/prettier': [
      'warn',
      {
        singleQuote: true,
        semi: false,
        trailingComma: 'none'
      }
    ],
    "node/no-unpublished-import": ["error", {
            "allowModules": [],
            "convertPath": null,
            "tryExtensions": [".js", ".json", ".node"]
    }]
  },
};
