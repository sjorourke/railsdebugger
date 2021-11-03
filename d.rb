# frozen_string_literal: true

class D
  def self.call_stack(suffix = '')
    outstr = ''
    caller(1).each { |ln| outstr += (ln + "\n") if ln.to_s.gsub!("#{Rails.root}/", '') }
    print_to_file(outstr, suffix)
  end

  def self.call_stack_thorough(suffix = '')
    outstr = ''
    caller(1).each { |ln| outstr += (ln.to_s.gsub!(ENV['HOME'], '~') || ln.to_s) + "\n" }
    print_to_file(outstr, suffix)
  end

  def self.print_hash(hash, suffix = '')
    print_to_file(hash_to_string(hash), suffix)
  end

  def self.hash_to_string(hash, indentation = '')
    ret = ''
    hash.sort_by { |k, _v| k.to_s }.each do |k, v|
      ret += indentation + k.to_s + truncated_ellipsis(k, v) + hash_value_to_string(v, indentation)
    end
    ret
  end

  def self.hash_value_to_string(value, current_indentation)
    if value.is_a?(Hash) && value.present?
      ":\n" + hash_to_string(value, "#{current_indentation}  ")
    else
      value.is_a?(Array) ? "[ #{value.join(', ')} ]\n" : value.to_s + "\n"
    end
  end

  def self.truncated_ellipsis(key, value)
    value.is_a?(Hash) && value.present? ? '' : " #{'.' * (75 - key.to_s.length)} "
  end

  def self.params(pass_in_self_through_here, suffix = '')
    hash = {
      params: pass_in_self_through_here.params.to_unsafe_hash,
      session: pass_in_self_through_here.session.to_hash,
      variables: pass_in_self_through_here.instance_variable_names.each_with_object({}) do |k, h|
        h[k] = pass_in_self_through_here.instance_variable_get(k)
      end
    }
    print_hash(hash, suffix)
  end

  def self.error_messages(object, suffix = '')
    errors_content = ''
    object.error_messages.each { |val| errors_content += "\n  " + val }
    print_to_file('errors:' + errors_content, suffix)
  end

  def self.print_to_file(output, file_suffix = '')
    File.open("#{ENV['HOME']}/sjo/sjo_temp#{file_suffix}.txt", 'w+') { |f| f.write(output) }
  end
end
