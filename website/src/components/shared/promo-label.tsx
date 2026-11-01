interface PromoLabelProps {
  className?: string;
  discount?: string;
  description?: string;
  discountColor?: string;
}

export const PromoLabel = ({
  className,
  discount,
  description,
  discountColor = 'text-foreground',
}: PromoLabelProps) => {
  return (
    <p
      className={`text-muted-foreground text-center text-sm ${className ?? ''}`}>
      Get <span className={`font-semibold ${discountColor}`}>{discount}</span>{' '}
      {description}
    </p>
  );
};
