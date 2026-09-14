# System applications for yertengri, available on all users
{den, ...}: {
  den = {
    aspects.yertengri = {
      includes = with den.aspects; [
        applications._.firefox
      ];
    };
  };
}
