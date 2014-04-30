# CloakId

### Hide your database ids from users of your webapp.

Using sequential ids makes predicting the ids of other resources in your application simple, and can provide details
about how your app is growing (how many users, etc.) to current and potential competitors.   Obfuscating identifiers isn't
meant to be a primary means of providing security, but it can help to keep confidential information from being completely
public.

Making use of the gem will replace the identifier in URLs:
e.g.  http://my.railsapp.com/users/U3OFSP23

as well as in JSON representations of resources

e.g.
{"id":"U3OFSP23", "name": "Joe User", "active":true}

## Installation

Add this line to your application's Gemfile:

    gem 'cloak_id'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloak_id

## Usage

In your model files (that inherit from Active Record) add the 'cloak_id' call to enable the obfuscating of the ids.

    class User < ActiveRecord::Base
      cloak_id
    end

## Customizing your cloaking

The cloak_id method call takes an option hash that controls how the cloaking occurs:
<p>
<table>
  <tr>
    <th>option name</th>
    <th>description</th>
  </tr>
  <tr>
    <td>key</td>
    <td>The key to use for obfuscating identifier.   This can be either an integer or a string.   This is an optional
        parameter.  If the user does not provide one, then this will be based on the name of the model itself.  This
        means that "common" models (e.g. User) may have the same obfuscated values across different web apps.  To prevent
        this, the key should be explictly provided.
    </td>
  </tr>
  <tr>
    <td> prefix </td>
    <td> Obfuscating the identifier results in a string.  To better help developers understand what type of resource
         if being identified, an optional prefix may be specified.   If none is provided, then all cloaked identifiers
         will start with the letter 'X'.  This prefix must start with a alphabetic character.
    </td>
  </tr>
</table>

###Examples
This line will result in a cloaked identifier encoded with a specifically defined key, and the resulting cloaked identifier
will begin with UU.

    cloak_id key:'SampleKey', prefix:'UU'

After this call, most instances of the id will be replaced with the cloaked id.   This includes calls to serialize the
resoruce as XML or JSON, as well as when it is used as a parameter in forms, or in RESTful API calls.   The "id" call will
not change, as this gem does not actually change the underlying id of the object.   Just how it is displayed.

To access the cloaked id directly, you may call
    self.cloaked_id

Retrieving objects from the database from cloaked ids can happen in two ways

    ClassName.find(cloaked_id)
or

    ClassName.find_by_cloaked_id(cloaked_id)

Objects that have had their id cloaked will use a "smart" find method.   This method will inspect the id to see if it
appears to be a cloaked id (all cloaked ids must start with an alphabetic character), and if it does, then it will use
the find_by_cloaked_id method.   If it is numeric, or if it does not begin with the expected prefix, then it will fall
back to use the out-of-the-box find functionality.

Because of this logic, most cases will work without any changes to the code that makes use of the cloaked resource.

## What the gem does:

The cloak_id gem provides a way to "cloak" your identifiers.   This doesn't provide any real security, but instead makes it
less obvious to what the underlying database id of a resource really is.  This is desirable in cases where you want to make
it more difficult for users to guess identifiers, or for observers to judge how fast your application is growing.

This technique does not provide any real security - it only makes it more difficult for casual observers to guess resource
identifiers.

The logic behind the transformation is to use a prime number to generate a simple, yet reversible hash of the database id.
That newly obscured hash is then encoded as a string, to further hide its meaning.  This will happen when generating forms
from ActiveRecords (when using the entire object or the to_param call), as well as when encoding the object in JSON format.




## Contributing

1. Fork it ( https://github.com/elleleb/cloak_id/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
