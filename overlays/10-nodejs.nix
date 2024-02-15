self: super: with super; {
  nodejs = nodejs-18_x;
  yarn = (yarn.override { inherit nodejs;});
  nodePackages = (nodePackages.override { inherit nodejs;});
}
