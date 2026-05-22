import { defineConfig } from "vite";
import elm from "vite-plugin-elm";
import tailwindcss from "@tailwindcss/vite";

export default defineConfig({
  base: "/elm-lustre-ui/",
  plugins: [tailwindcss(), elm()],
});
