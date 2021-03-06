requires "DBIx::Class" => "0";
requires "DBIx::Class::Candy" => "0";
requires "DBIx::Class::Helpers" => "0";
requires "Moo" => "0";
requires "base" => "0";
requires "namespace::autoclean" => "0";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "File::Spec" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::DBIx::Class" => "0";
  requires "Test::More" => "0.96";
  requires "Test::Most" => "0";
  requires "blib" => "1.01";
  requires "perl" => "5.006";
  requires "SQL::Translator" => 0;
};

on 'test' => sub {
  recommends "CPAN::Meta" => "2.120900";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
};

on 'develop' => sub {
  requires "Test::Pod" => "1.41";
};
