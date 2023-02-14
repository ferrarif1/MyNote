import {uglify} from "rollup-plugin-uglify";

export default {
  input: './coinstart.js',
  output: {
    file: 'coinstart.min.js',
    format: 'iife'
  },
  plugins: [
    uglify()
  ]
};