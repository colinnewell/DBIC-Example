package DBIC::Example::Schema;

our $VERSION = '1';

use Moo;
use namespace::autoclean;

extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces();


1;
