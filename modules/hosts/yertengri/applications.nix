# System applications for yertengri
{den, ...}: {
  den = {
    aspects.yertengri = {
      includes = with den.aspects; [
        applications._.firefox
      ];
    };
  };
}
