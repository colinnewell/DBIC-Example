package DBIC::Example::Schema::Result::OrderItem;

use DBIx::Class::Candy -autotable => v1,
                    -components => [qw/
                        Helper::Row::ToJSON
                        InflateColumn::DateTime
                        TimeStamp
                        /];

primary_column id => {
    data_type => 'int',
    is_auto_increment => 1,
};

column order_id => {
    data_type => 'int',
};

column name => {
    data_type => 'varchar',
    size => 25,
    is_nullable => 0,
};

column type => {
    data_type => 'text',
    is_nullable => 0,
};

column per_item => {
    data_type => 'numeric',
    is_nullable => 0,
};

column quantity => {
    data_type => 'numeric',
    is_nullable => 0,
};

column vat => {
    data_type => 'numeric',
    is_nullable => 0,
};

belongs_to order => 'DBIC::Example::Schema::Result::Order' => 'order_id';


1;

