require('esbuild').build({
  entryPoints: ['index.ts'],
  bundle: true,
  outfile: '.bundle/index.js',
  platform: 'node',
  target: 'node20',
})
