package DBIC::Example::Schema;

use Moo;
use namespace::autoclean;

extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces();


1;
