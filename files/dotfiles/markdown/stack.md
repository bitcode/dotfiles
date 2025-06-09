### his is to keep track of my development stack notes and Installs

- Install Next.js 
<br>
    `npx create-next-app@latest --typescript`
<br>
- Install Material UI, Styled Components 
<br>
`npm install @mui/material @mui/styled-engine-sc styled-components @emotion/react @emotion/styled @swc/plugin-styled-components`
<br>
- Configure webpack.alias.js bundler to use @mui/styled-engine-sc instead of emotion 
<br>
`
module.exports = {
   //...
   resolve: {
     alias: {
       '@mui/styled-engine': '@mui/styled-engine-sc'
     },
   },
 };
`
<br>
    - if using typescript, add to tsconfig.json
`
{
   "compilerOptions": {
    "paths": {
      "@mui/styled-engine": ["./node_modules/@mui/styled-engine-sc"]
    }
   },
 }
`
<br>
